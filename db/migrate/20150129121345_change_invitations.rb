class ChangeInvitations < ActiveRecord::Migration
  def change
	 ActiveRecord::Base.connection.execute("TRUNCATE invitations")
	 ActiveRecord::Base.connection.execute("TRUNCATE invitation_codes")
	remove_column :invitations, :invitee_name
	remove_column :invitations, :invitee_email
	remove_column :invitations, :invitation_sent_at
	remove_column :invitations, :status
	add_reference :invitations, :invitation_code, index: true

       remove_column :invitation_codes, :invitation_id
       add_reference :invitation_codes, :user, index: true
       add_column :invitation_codes, :out_to, :string
       add_column :invitation_codes, :status, :string
  end
end
