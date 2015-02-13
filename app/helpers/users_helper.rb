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

end
