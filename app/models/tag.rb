class Tag < ActiveRecord::Base
 has_many  :users, :through => :user_tags
 has_many :user_tags, :dependent => :destroy  


def self.get_tag_set tags
	tag_array =Array.new
	tags.each do |tag|
		user_tag = tag.user_tags.take
		tag_array <<	{:name => tag.name}
	end
tag_array
end

end
