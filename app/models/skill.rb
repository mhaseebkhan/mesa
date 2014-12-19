class Skill < ActiveRecord::Base
 has_many  :users, :through => :user_skills
 has_many :user_skills, :dependent => :destroy  


def self.get_skill_set skills
	skill_array =Array.new
	skills.each do |skill|
		user_skill = skill.user_skills.take
		skill_array <<	{:name => skill.name,
		:work_ref => user_skill.work_ref,
		:company => user_skill.company,
		:time_spent => user_skill.time_spent,
		:founded => user_skill.founded
		}
	end
skill_array
end

end
