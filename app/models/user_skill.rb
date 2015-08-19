class UserSkill < ActiveRecord::Base
 belongs_to :user
 belongs_to :skill
 has_many :user_ratings
end
