class CreateInvitationCodes < ActiveRecord::Migration
  def change
    create_table :invitation_codes do |t|
      t.string :code_text
      t.references :invitation, index: true
      t.timestamps
    end
  end
end
