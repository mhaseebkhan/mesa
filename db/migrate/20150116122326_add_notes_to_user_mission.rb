class AddNotesToUserMission < ActiveRecord::Migration
  def change
	remove_column :user_ratings, :notes
	add_column :user_missions, :notes, :string
  end
end
