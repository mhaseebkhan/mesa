class CreateUserRatings < ActiveRecord::Migration
  def change
    create_table :user_ratings do |t|
      t.integer :rating
      t.string :notes
      t.references :user_skill, index: true

      t.timestamps
    end
  end
end
