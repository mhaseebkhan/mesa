class AddIsNewAdminToUsers < ActiveRecord::Migration
  def change
	add_column :users, :is_new_admin, :boolean, :default => false
  end
end
