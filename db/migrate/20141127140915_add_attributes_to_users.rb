class AddAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :profile_pic, :string
    add_column :users, :city, :text
    add_column :users, :working_at, :string
    add_column :users, :languages, :string
    add_column :users, :passions, :string
  end
end
