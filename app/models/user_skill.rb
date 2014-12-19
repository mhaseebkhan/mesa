class UserSkill < ActiveRecord::Base
 belongs_to :user
 belongs_to :skill
 has_one :user_rating
end
