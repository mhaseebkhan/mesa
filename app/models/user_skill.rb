class UserSkill < ActiveRecord::Base
 belongs_to :users
 belongs_to :skills
 has_one :user_ratings
end
