class Mission < ActiveRecord::Base
 has_many  :users, :through => :user_missions
 has_many :user_missions, :dependent => :destroy  

 def self.exists? id
	Mission.find_by_id(id)
 end
end
