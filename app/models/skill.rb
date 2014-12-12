class Skill < ActiveRecord::Base
 has_many  :users, :through => :user_skills
 has_many :users, :dependent => :destroy  
end
