class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :invitee_email
      t.string :invitee_name
      t.datetime :invitation_sent_at
      t.text :status
      t.references :user, index: true
      t.timestamps
    end
  end
end
