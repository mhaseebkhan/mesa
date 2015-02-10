class Skill < ActiveRecord::Base
 has_many  :users, :through => :user_skills
 has_many :user_skills, :dependent => :destroy  


def self.get_skill_set (skills,user_id)
	skill_array =Array.new
	skills.order('skill_id ASC').each do |skill|
		user_skill = skill.user_skills.where(user_id: user_id).take
		skill_array <<	{:id => skill.id,
		:name => skill.name,
		:work_ref => user_skill.work_ref,
		:company => user_skill.company,
		:time_spent => user_skill.time_spent,
		:founded => user_skill.founded
		}
	end
skill_array
end

def self.get_skill_rating(skills,mesa_id,user_id)
	skill_array =Array.new
	skills.order('skill_id ASC').each do |skill|
		user_skill = skill.user_skills.where(user_id: user_id).take
		user_rating = user_skill.user_ratings.where(mission_id: mesa_id).take if user_skill.user_ratings
		unless user_rating.nil?
			rating = user_rating.rating 
			skill_array <<	{:id => skill.id,
			:name => skill.name,
			:rating => rating 
			}
		end
	end
skill_array
end

def self.get_average_skill_rating(skills,user_id)
	skill_array =Array.new
	skills.order('skill_id ASC').each do |skill|
		user_skill = skill.user_skills.where(user_id: user_id).take
		unless user_skill.user_ratings.empty?
			skill_rating = Array.new
			user_skill.user_ratings.collect{|user_rating| skill_rating << user_rating.rating} if user_skill.user_ratings
			unless skill_rating.nil?
				rating = skill_rating.sum / skill_rating.size.to_f
				skill_array <<	{:id => skill.id,
				:name => skill.name,
				:rating => rating.to_i 
				}
			end
		end
	end
skill_array
end

end
