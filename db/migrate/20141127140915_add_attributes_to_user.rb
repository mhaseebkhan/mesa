class AddAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :skill, :string
    add_column :users, :tag, :string
    add_column :users, :passion, :string
    add_column :users, :working_at, :string
    add_column :users, :experience, :string
    add_column :users, :languages, :string
    add_column :users, :role_id, :string
  end
end
