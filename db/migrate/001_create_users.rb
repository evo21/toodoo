class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name   # is this assigned in toodoo.rb -- line 31?
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end