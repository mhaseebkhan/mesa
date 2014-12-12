class UserMission < ActiveRecord::Base
 belongs_to :users
 belongs_to :missions
end
