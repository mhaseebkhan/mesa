class UserMission < ActiveRecord::Base
 belongs_to :user
 belongs_to :mission

 def self.exists?(user_id,mesa_id)
        mesa_invitation= nil
	if ((User.exists? user_id) && (Mission.exists? mesa_id))
		mesa_invitation = UserMission.where(user_id: user_id, mission_id: mesa_id).exists? ? nil : true
        end
        mesa_invitation
 end
end
