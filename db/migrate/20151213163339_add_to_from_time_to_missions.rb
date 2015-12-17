class AddToFromTimeToMissions < ActiveRecord::Migration
  def change
	remove_column :missions, :time
	add_column :missions, :to_time, :string
        add_column :missions, :from_time, :string
  end
end
