class CreateMesaChairUsers < ActiveRecord::Migration
  def change
    create_table :mesa_chair_users do |t|
      t.references :user, index: true
      t.references :mesa_chair, index: true
      t.timestamps
    end
  end
end
