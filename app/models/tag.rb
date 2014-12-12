class Tag < ActiveRecord::Base
 has_many  :users, :through => :user_tags
 has_many :users, :dependent => :destroy  
end
