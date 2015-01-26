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
    name = ask("Username?") { |q| q.validate = /\A\w+\Z/ }
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
    delete = ask("Are you *sure* you want to stop using TooDoo?") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @user.destroy
      @user = nil
    end
  end

  def new_list
    say("Creating a new ToDo List/Category: ie. 'Groceries', 'School'")
    
    name = ask("List Category or Title of your new ToDo List-(250 characters or less)?") { |q| q.validate = /\A\w+\Z/ }
    @list = Toodoo::List.create(:name => name, :user_id => @user.id)

    #@user.lists.create(:name => name)
    say("Thanks #{@user.name}! Let's add some Tasks for this List: ")

  end

  def pick_list
    choose do |menu|
      # TODO: This should get get the todo lists for the logged in user (@user).
      # Iterate over them and add a menu.choice line as seen under the login method's
      # find_each call. The menu choice block should set @todos to the todo list.

      menu.choice(:back, "Just kidding, back to the main menu!") do
        say "You got it!"
        @lists = nil
      end
    end
  end

  def delete_list
    # TODO: This should confirm that the user wants to delete the todo list.
    # If they do, it should destroy the current todo list and set @todos to nil.
  end

  def get_and_save_due_date(task)
    task.due_date = ask("When should this task be completed?") do |q|
      q.default = Date.today.to_s;
      q.validate = lambda { |p| Date.parse(p) >= Date.today }
      q.responses[:not_valid] = "Enter a date greater than or equal to today"
    end
    task.save
  end
  
  def new_task
    say("Creating some ToDo's as part of the #{'@list'} List: ")    
    name = ask("What Tasks would you like to add to this current ToDo List?")
    binding.pry
    newtask = @list.tasks.create(:name => name)
    choices = 'yn'
    duedate = ask("Thanks #{@user.name}! Is there a Due Date for this Task?") { |q| q.validate = /\A[#{choices}]\Z/ }
    if duedate == 'y'
      get_and_save_due_date(newtask)
    end
  end

  ## NOTE: For the next 3 methods, make sure the change is saved to the database.
  def mark_done
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should update the todo to be completed.
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
    binding.pry
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        menu.layout = :menu_only
        menu.shell = true

        # Are we logged in yet?
        unless @user
          menu.choice(:new_user, "Create a new user.") { new_user }
          menu.choice(:login, "Login with an existing account.") { login }
        end

        # We're logged in. Do we have a todo list selected to work on?
        if @user && !@list
          menu.choice(:delete_account, "Delete the current user account.") { delete_user }
          menu.choice(:new_list, "Create a new todo list.") { new_list }
          menu.choice(:pick_list, "Work on an existing list.") { pick_list }
          menu.choice(:remove_list, "Delete a todo list.") { delete_list }
        end

        # Let's work on some todos!
        if @user && @list
          menu.choice(:new_task, "Add a new task.") { new_task }
          menu.choice(:mark_done, "Mark a task finished.") { mark_done }
          menu.choice(:move_date, "Change a task's due date.") { change_due_date }
          menu.choice(:edit_task, "Update a task's description.") { edit_task }
          menu.choice(:show_done, "Toggle display of tasks you've finished.") { @show_done = !!@show_done }
          menu.choice(:show_overdue, "Show a list of task's that are overdue, oldest first.") { show_overdue }
          menu.choice(:back, "Go work on another Toodoo list!") do
            say "You got it!"
            @lists = nil
          end
        end

        menu.choice(:quit, "Quit!") { exit }
      end
    end
  end
end

#binding.pry

todos = TooDooApp.new
todos.run


# rake db:migrate
# bundle exec ruby lib/toodoo.rb
