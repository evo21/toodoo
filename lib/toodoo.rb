require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  class User < ActiveRecord::Base
    has_many :lists
  end

  class List < ActiveRecord::Base
    belongs_to :user
    has_many :tasks
  end

  class Task < ActiveRecord::Base
    belongs_to :list
  end
end

class TooDooApp
  def initialize
    @user = nil
    @lists = nil
    @show_done = nil
  end

  def new_user
    say("Creating a new user:")
    name = ask("Username?") { |q| q.validate = /\A\w+|\Z/ }
    @user = Toodoo::User.create(:name => name)
    say("We've created your account and logged you in. Thanks #{@user.name}!")
  end

  def login
    choose do |menu|
      menu.prompt = "Please choose an account - enter Username: "

      Toodoo::User.find_each do |u|
        menu.choice(u.name, "Login as #{u.name}.") { @user = u }
      end

      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @user = nil
      end
    end
  end

  def delete_user
    choices = 'yn'
    delete = ask("Are you *sure* you want to stop using TooDoo? y/n") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
    end
    if delete == 'y'
      say("User: **#{@user.name}** Deleted!")
      @user.destroy
      @user = nil
    end
  end

  def new_list
    say("Creating a new ToDo List/Category: ie. 'Groceries', 'School'")
    
    name = ask("List Category or Title of your new ToDo List-(250 characters or less)?") { |q| q.validate = /\A\w+\Z/ }
    @list = Toodoo::List.create(:name => name, :user_id => @user.id)
    say("Thanks #{@user.name}! Let's add some Tasks for this List: ")

  end

  def pick_list
    choose do |menu|
      menu.prompt = "Choose a Category/ToDo List: "
      @user.lists.find_each do |l|
        menu.choice(l.name, "Choose List: #{l.name}.") { @list = l }
        end
      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @list = nil
      end
    end
  end

  def delete_list
    choose do |menu|
      menu.prompt = "Choose a Category/ToDo List to Delete: "
      @user.lists.find_each do |l|
        menu.choice(l.name, "Choose List: #{l.name}.") { @list = l }
        end
      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @list =  nil
        break
      end
    end
      choices = 'yn'
      delete = ask("Are you SURE you want Delete the **#{@list.name}** ToDo List?") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
    end
    if delete == 'y'
      say("**#{@list.name}*** List Deleted!")
      @list.destroy
      @list = nil
    else
      say "Returning to previous menu..."
      @list = nil
    end
  end

  def get_and_save_due_date(task)
    task.due_date = ask("When should this task be completed?") do |q|
      q.default = Date.today.to_s;
      q.validate = lambda { |p| Date.parse(p) >= Date.today }
      q.responses[:not_valid] = "Enter a date of today or later"
    end
    task.save
  end
  
  def new_task
    say("Creating some ToDo's for your List:")    
    name = ask("**#{@list.name}** What Task(s) to add?")
    newtask = @list.tasks.create(:name => name)
    choices = 'yn'
    duedate = ask("Thanks #{@user.name}! Is there a Due Date for this Task? y/n") { |q| q.validate = /\A[#{choices}]\Z/ }
    if duedate == 'y'
      get_and_save_due_date(newtask)
    end
  end

  ## NOTE: For the next 3 methods, make sure the change is saved to the database.
  def show_tasks_and_mark_done
    task = choose do |menu|
      menu.prompt = "Tasks for #{@user.name}'s **#{@list.name}** ToDo List:\nChoose Task to mark **Completed**:"
      @list.tasks.where(done: false).find_each do |t|
        menu.choice(t.name, "XXXXXX") {@task = t}
        end
      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @task = nil
        break
      end
    end
    say("**#{@task.name}*** marked Done!")
    @task.done = true
    task.save
    @task = nil
  end

  def change_due_date
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should update the due date for the todo. You probably want to use
    # `ask("foo", Date)` here.
  end

  def edit_task
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should change the name of the todo.
  end

  def show_overdue
    # TODO: This should print a sorted list of todos with a due date *older*
    # than `Date.now`. They should be formatted as follows:
    # "Date -- Eat a Cookie"
    # "Older Date -- Play with Puppies"
  end

  def run
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        #menu.layout = :menu_only
        #menu.shell = true

        # Are we logged in yet?

        binding.pry

        unless @user
          menu.choice("Create a new user.", :new_user) { new_user }
          menu.choice("Login with an existing account.", :login) { login }
        end

        # We're logged in. Do we have a todo list selected to work on?
        if @user && !@list
          say("User: #{@user.name}:")
          menu.choice("Delete the current user account.", :delete_account) { delete_user }
          menu.choice("Create a new ToDo list.", :new_list) { new_list }
          menu.choice("Work on an existing ToDo list.", :pick_list) { pick_list }
          menu.choice("Delete an Existing ToDo list.", :remove_list) { delete_list }
        end

        # Let's work on some todos!
        if @user && @list
          say("#{@user.name}'s #{@list.name} ToDo List:")
          menu.choice("Add a new task.", :new_task) { new_task }
          menu.choice("Mark a task finished.", :mark_done) { show_tasks_and_mark_done }
          menu.choice("Change a task's due date.", :move_date) { change_due_date }
          menu.choice("Update a task's description.", :edit_task) { edit_task }
          menu.choice("Toggle display of tasks you've finished.", :show_done) { @show_done = !!@show_done }
          menu.choice("Show a list of task's that are overdue, oldest first.", :show_overdue) { show_overdue }
          menu.choice(:back, "Go work on another Toodoo list!") do
            say "You got it!"
            @list = nil
          end
        end

        menu.choice(:quit, "Quit!") { exit }
      end
    end
  end
end

todos = TooDooApp.new
todos.run


# rake db:migrate
# bundle exec ruby lib/toodoo.rb
