class AddedTag < ActiveRecord::Base
	belongs_to :user
	belongs_to :mission
	belongs_to :tag

def self.get_tag_set tags
	tag_array =Array.new
	tags.each do |tag|
		tag_name = Tag.find(tag.tag_id).name
		tag_array <<{:name => tag_name}
	end
tag_array
end

end
