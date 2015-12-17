class CreateCuratorCodes < ActiveRecord::Migration
  def change
    create_table :curator_codes do |t|
      t.integer :no_of_codes
      t.integer :code_frequency
      t.datetime :last_code_time
      t.text :status
      t.references :user, index: true
      t.timestamps
    end
  end
end
