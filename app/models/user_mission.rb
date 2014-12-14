class UserMission < ActiveRecord::Base
 belongs_to :user
 belongs_to :mission
end
