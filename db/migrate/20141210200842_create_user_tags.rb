class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.references :user, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
