class Mission < ActiveRecord::Base
 has_many  :users, :through => :user_missions
 has_many :user_missions, :dependent => :destroy  
end
