class CreateUnconciousUsers < ActiveRecord::Migration
  def change
    create_table :unconcious_users do |t|
	    t.text :name
	    t.text :profile_pic
	    t.text :city
	    t.text :working_at
	    t.text :languages
	    t.text :passions
	    t.text :tags
	    t.text :skills
            t.timestamps
    end
  end
end
