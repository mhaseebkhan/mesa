class AddInvitesOutToMission < ActiveRecord::Migration
  def change
	 add_column :missions, :invites_out, :datetime
  end
end
