module UsersHelper

def stringify_tags tags
	if tags
		tag_array = Array.new
		tags.collect {|tag| tag_array << tag[:name].humanize}
		tag_array.join(",")
	else
		'No Tags'
	end
end

def get_user_img
	current_user.profile_pic.present? ? current_user.profile_pic : 'user.png'
end

def get_un_rated_skills(rated_skills, all_skills)
	rated_skills.each do |rated_skill|
		all_skills.delete_if{|skill| skill[:id] == rated_skill[:id]}
	end
	all_skills	
end
# A user is marked as inactive IF he has NEVER participated in ANY MESA
def inactive_user(user_id)
	UserMission.find_by(user_id:  user_id) ? false : true
end

end
