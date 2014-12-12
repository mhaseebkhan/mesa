class Mission < ActiveRecord::Base
 has_many  :users, :through => :user_missions
 has_many :users, :dependent => :destroy  
end
