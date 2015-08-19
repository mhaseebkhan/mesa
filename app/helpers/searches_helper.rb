module SearchesHelper

	def user_is_already_invited(user_id,mesa_id)
		UserMission.where(user_id: user_id,mission_id: mesa_id,invitation_status: ACCEPTED_MESA_INVITATION)	
	end
        def user_is_already_assigned_chair(user_id,mesa_id)
		user_found = true
		MesaChair.where(mission_id: mesa_id).collect{|chair|  user_found = false if chair.mesa_chair_users.pluck(:user_id).include?(user_id)}
		user_found
	end
	def pending_invitation(user_id,mesa_id)
		invitation = UserMission.where(user_id: user_id,mission_id: mesa_id).take
	end

end
