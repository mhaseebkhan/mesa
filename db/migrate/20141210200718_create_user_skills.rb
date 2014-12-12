class CreateUserSkills < ActiveRecord::Migration
  def change
    create_table :user_skills do |t|
      t.text :time_spent
      t.text :company
      t.string :work_ref
       t.references :user, index: true
      t.references :skill, index: true

      t.timestamps
    end
  end
end
