module MissionsHelper
 def get_mission_owner mission
	owner = mission.get_mission_owner 
	owner[:name]
 end

end
