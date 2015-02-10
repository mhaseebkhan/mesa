class UserMission < ActiveRecord::Base
 belongs_to :user
 belongs_to :mission
 has_many :mesa_chairs
 def self.exists?(user_id,mesa_id)
        mesa_invitation= nil
	if ((User.exists? user_id) && (Mission.exists? mesa_id))
		mesa_invitation = UserMission.where(user_id: user_id, mission_id: mesa_id).exists? ? nil : true
        end
        mesa_invitation
 end

  #Check if mesa invite has passed 18 hours
  def mesa_invitation_not_expired
	if self.invitation_time

		if  self.invitation_time.to_date == Time.now.utc.to_date - 1
			Time.now.utc.hour - self.invitation_time.hour >= 6 ?  false : true
		elsif  self.invitation_time.to_date < Time.now.utc.to_date - 1
			false
		else
			true
		end

	end
  end

 def allocate_time_slot_to_next_user
	next_user_in_chair_list = UserMission.where(id: self.id+1, invitation_status: WAITING_MESA_INVITATION, mission_id: self.mission_id).take	
	if next_user_in_chair_list
		next_user_in_chair_list.update_attributes(invitation_time: Time.now.utc, invitation_status: PENDING_MESA_INVITATION )
	end
 end

end
