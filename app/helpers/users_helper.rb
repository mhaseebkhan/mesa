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

end
