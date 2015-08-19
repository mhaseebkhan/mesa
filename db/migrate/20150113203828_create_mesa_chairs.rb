class CreateMesaChairs < ActiveRecord::Migration
  def change
    create_table :mesa_chairs do |t|
      t.references :user_mission
      t.references :mission, index: true
      t.integer :order
      t.timestamps
    end
  end
end
