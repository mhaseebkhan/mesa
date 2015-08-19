module MissionsHelper
 def get_mission_owner mission
	owner = mission.get_mission_owner 
	owner[:name]
 end
 
 def check_all_invites_out(mission_id)
	UserMission.where(mission_id: mission_id).pluck(:invitation_status).include?(PENDING_MESA_INVITATION)
	#  Invitation.mesa_invitation_not_expired(invites_out_time)
 end

end
