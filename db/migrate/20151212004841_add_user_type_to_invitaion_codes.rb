class AddUserTypeToInvitaionCodes < ActiveRecord::Migration
  def change
	add_reference :invitation_codes, :role, index: true
  end
end
