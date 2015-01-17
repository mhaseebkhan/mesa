module SearchesHelper

	def user_is_already_invited(user_id,mesa_id)
		UserMission.where(user_id: user_id,mission_id: mesa_id,invitation_status: ACCEPTED_MESA_INVITATION)	
	end
        def user_is_already_assigned_chair(user_id,mesa_id)
		MesaChair.where(user_id: user_id,mission_id: mesa_id)	
	end
	def pending_invitation(user_id,mesa_id)
		UserMission.where(user_id: user_id,mission_id: mesa_id,invitation_status: PENDING_MESA_INVITATION)	
	end
end
