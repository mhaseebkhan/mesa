class CreateAddedTags < ActiveRecord::Migration
  def change
   create_table :added_tags do |t|
      t.references :tag, index: true
      t.references :user, index: true
      t.references :mission, index: true
      t.timestamps
     end
  end
end
