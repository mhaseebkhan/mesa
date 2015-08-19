class AddCreatedByInMission < ActiveRecord::Migration
  def change
	 add_column :missions, :owner_id, :int
  end
end
