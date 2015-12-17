class CreateUserMissions < ActiveRecord::Migration
  def change
    create_table :user_missions do |t|
      t.text :invitation_status
      t.datetime :invitation_time
      t.references :user, index: true
      t.references :mission, index: true
      t.timestamps
    end
  end
end
