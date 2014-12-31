class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  
  has_many  :skills, :through => :user_skills
  has_many :user_skills, :dependent => :destroy  
  has_many  :tags, :through => :user_tags
  has_many :user_tags, :dependent => :destroy  
  has_many  :missions, :through => :user_missions
  has_many :user_missions, :dependent => :destroy  
  has_many :invitations
  has_one :curator_codes
  has_many :roles, :through => :user_roles
  has_many :user_roles,:dependent => :destroy  

  mount_uploader :profile_pic, ImageUploader
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
				UserSkill.create( user_id: self.id, skill_id: skill_found.id, work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded] )
			end
		end
		if (profile[:tags])
			profile[:tags].each do |tag|
				tag_found = Tag.find_or_create_by(name: tag[:name])
				UserTag.create( user_id: self.id, tag_id: tag_found.id)
			end
		end
		UserRole.create(user_id: self.id, role_id: ROLE_COMMONFLAGGER)
           
  end

  def update_profile(profile)
	  self.update_attributes(name: profile[:name], city: profile[:city], languages: profile[:languages].to_s,working_at: profile  [:working_at], profile_pic: profile[:profile_pic],passions: profile[:passions].to_s) 
		if (profile[:skills])
			UserSkill.where(user_id: self.id).delete_all
			profile[:skills].each do |skill|
				skill_found = Skill.find_or_create_by(name: skill[:name])
				UserSkill.create( user_id: self.id, skill_id: skill_found.id, work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded] )
			end
		end
		if (profile[:tags])
			UserTag.where(user_id: self.id).delete_all
			profile[:tags].each do |tag|
				tag_found = Tag.find_or_create_by(name: tag[:name])
				UserTag.create( user_id: self.id, tag_id: tag_found.id)
			end
		end
  end


  def get_profile
       skills = self.skills
       skill_array = Skill.get_skill_set skills if skills
       skills = self.tags
       tag_array = Tag.get_tag_set tags if tags
	
	{:email=> self.email,:profile =>{:name=>self.name,:city => self.city, :languages=>self.languages,:working_at => self.working_at,:skills=> skill_array,:tags => tag_array,:passions => self.passions}}
  end
  
  def self.email_exists? email
	User.find_by_email(email)
  end

  def self.exists? id
	User.find_by_id(id)
  end
  
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  
end
