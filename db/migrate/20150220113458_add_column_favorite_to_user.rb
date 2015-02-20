class AddColumnFavoriteToUser < ActiveRecord::Migration
  def change
    add_column :users, :favorite, :boolean, default: false
  end
end
