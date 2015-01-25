class CreateListsAndTasks < ActiveRecord::Migration  # what is 'CreateXxx' the 'Create' part
  def self.up                                 # I changed this from class CreateTodoLists and didn't work??
    create_table :lists do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.integer :list_id
      t.date :due_date
      t.date :done_date
      t.boolean :done, default: false
      t.timestamps
    end

  end

  def self.down
    drop_table :lists
    drop_table :tasks
  end

end