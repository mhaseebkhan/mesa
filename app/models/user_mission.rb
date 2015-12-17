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
			Time.now.utc.hour - self.invitation_time.hour >= 6 ?  true : false
		elsif  self.invitation_time.to_date < Time.now.utc.to_date - 1
			false
		else
			#check if 18 hrs have passed in same day			
			Time.now.utc.hour - self.invitation_time.hour >= 18 ?  false : true
		end

	end
  end

 def allocate_time_slot_to_next_user
	next_user_in_chair_list = UserMission.where(id: self.id+1, invitation_status: WAITING_MESA_INVITATION, mission_id: self.mission_id).take	
	if next_user_in_chair_list
		user = User.find(next_user_in_chair_list.user_id)
                user_role = user.role?
		if user_role == ROLE_HARDINPUT
			next_user_in_chair_list.update_attributes(invitation_time: Time.now.utc, invitation_status: ACCEPTED_MESA_INVITATION )
                else
			next_user_in_chair_list.update_attributes(invitation_time: Time.now.utc, invitation_status: PENDING_MESA_INVITATION )
			#send email to next user
				mission = Mission.exists? next_user_in_chair_list.mission_id
				mission_title = mission.title
				mesa_owner = mission.get_mission_owner 
		                email = user.email
				UserMailer.send_mesa_invitation_email(mesa_owner[:name],mission_title,email).deliver
			#send push notification
				data = { :alert => "You have received a Mesa Invitation", :userId =>next_user_in_chair_list.user_id, :mesaId => next_user_in_chair_list.mission_id, :sound => "cheering.caf"}
				push = Parse::Push.new(data)
				query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).eq('userId', next_user_in_chair_list.user_id.to_i)
				push.where = query.where
				push.save
		end
	end
 end

end
