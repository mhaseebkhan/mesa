class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  belongs_to :role
  has_many  :skills, :through => :user_skills
  has_many :skills, :dependent => :destroy  
  has_many  :tags, :through => :user_tags
  has_many :tags, :dependent => :destroy  
  has_many  :missions, :through => :user_missions
  has_many :user_missions, :dependent => :destroy  
  has_many :invitations
  has_one :curator_codes
  
  before_save :ensure_authentication_token
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
  
  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
    self.save!
  end
 
  def build_profile(profile)
	  self.update_attributes(name: profile[:name], city: profile[:city], languages: profile[:languages].to_s,working_at: profile  [:working_at], profile_pic: profile[:profile_pic],passions: profile[:passions].to_s) 
		if (profile[:skills])
			profile[:skills].each do |skill|
				skill_found = Skill.find_or_create_by(name: skill[:name])
				UserSkill.create( user_id: self.id, skill_id: skill_found.id, work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent] )
			end
		end
		if (profile[:tags])
			profile[:tags].each do |tag|
				tag_found = Tag.find_or_create_by(name: tag[:name])
				UserTag.create( user_id: self.id, tag_id: tag_found.id)
			end
		end
  end
  
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  
end
