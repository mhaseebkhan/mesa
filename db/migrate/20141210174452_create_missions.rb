class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.string :title
      t.string :brief
      t.string :shared_motivation
      t.string :build_intent
      t.datetime :from_date
      t.datetime :to_date
      t.text :time
      t.text :place
      t.boolean :status
      t.boolean :is_authorized
      t.timestamps
    end
  end
end
