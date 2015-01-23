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
  has_many :added_tags
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
          #Set user attributes
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
                #Set user role
		UserRole.create(user_id: self.id, role_id: ROLE_COMMONFLAGGER)
                #Occupy code
		invitaion_code = InvitationCode.find_by_code_text(profile[:code])
		invitation = Invitation.where(id: invitaion_code.id, status: PENDING_INVITATION_STATUS).take.update_attribute(:status, TAKEN_INVITATION_STATUS) if invitaion_code
           
  end

 def update_profile(profile)
	  self.update_attributes(name: profile[:name], city: profile[:city], languages: profile[:languages].to_s,working_at: profile  [:working_at], profile_pic: profile[:profile_pic],passions: profile[:passions].to_s) 
                # this code will only add new skills, will not delete the missing ones, as if we delete them, their relevany star rating would also be gone
		if (profile[:skills])
			#existing_skills = UserSkill.where(user_id: self.id).pluck(:id)
			#profile[:skills].each do |skill|
			#	skill_found = Skill.find_by_name(skill[:name])
			#	existing_skills.delete_if{|existing_skill_id| existing_skill_id == skill_found.id}
			#	if skill_found
			#		user_skill = UserSkill.find_or_create_by(user_id: self.id, skill_id: skill_found.id)
			#		user_skill.update_attributes( work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded])
			#	else
			#		new_skill = Skill.create(name: skill[:name])
			#		UserSkill.create( user_id: self.id, skill_id: new_skill.id, work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded] )

			#	end
			#end
			#UserSkill.where(id: existing_skills).delete_all
			UserSkill.where(user_id: self.id).delete_all
			profile[:skills].each do |skill|
				skill_found = Skill.find_or_create_by(name: skill[:name])
				user_skill = UserSkill.find_or_create_by(user_id: self.id, skill_id: skill_found.id)		
				user_skill.update_attributes( work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded])
			end
			
		end
		if (profile[:tags])
			#existing_tags = UserTag.where(user_id: self.id).pluck(:id)
			#profile[:tags].each do |tag|
			#	tag_found = Tag.find_or_create_by(name: tag[:name])
			#	existing_tags.delete_if{|existing_tag_id| existing_tag_id == tag_found.id}
			#	UserTag.find_or_create_by( user_id: self.id, tag_id: tag_found.id)
			#end
			#UserTag.where(id: existing_tags).delete_all
			UserTag.where(user_id: self.id).delete_all
			profile[:tags].each do |tag|
				tag_found = Tag.find_or_create_by(name: tag[:name])
				UserTag.find_or_create_by( user_id: self.id, tag_id: tag_found.id)
			end
		end
  end



  def get_profile
       skills = self.skills
       skill_array = Skill.get_skill_set skills if skills
       tags = self.tags
       tag_array = Tag.get_tag_set tags if tags
	
	{:email=> self.email,:profile =>{:id => self.id,:name=>self.name,:profile_pic => self.profile_pic.url.to_s,:city => self.city, :languages=>self.languages,:working_at => self.working_at,:skills=> skill_array,:tags => tag_array,:passions => self.passions}}
  end

  def self.email_exists? email
	User.find_by_email(email)
  end

  def self.exists? id
	User.find_by_id(id)
  end
 
  def role? 
	if self.roles.first.nil?
		UserRole.create(user_id: self.id, role_id: ROLE_COMMONFLAGGER)
		ROLE_CURATOR
	else
		self.roles.first.id
	end
  end

  def get_primary_info id
        user = User.find_by_id(id)
	{:id => user.id, :name=>user.name, :profile_pic => user.profile_pic.url.to_s }
  end

  
  def rate_profile(params)
		#Add new tags
		if (params[:new_tags])
			params[:new_tags].each do |tag|
				tag_found = Tag.find_by_name(tag)
				if tag_found
					AddedTag.find_or_create_by( mission_id: params[:mesa_id],user_id: params[:user_id],tag_id: tag_found.id)
				else
					new_tag = Tag.create(name: tag)
					AddedTag.create( mission_id: params[:mesa_id],user_id: params[:user_id],tag_id: new_tag.id)
				end
			end
		end
		# Add skill rating for mesa
		if (params[:star_rating])
			params[:star_rating].each do |skill|
				skill_rate = skill.split("_")[0]
				skill_id = skill.split("_")[1]
				skill_found = UserSkill.where(user_id: params[:user_id], skill_id: skill_id).take.id
				rating_found = UserRating.where(user_skill_id: skill_found, mission_id: params[:mesa_id] )
				unless rating_found.empty?
					rating_found.take.update_attribute(:rating, skill_rate)
				else
					UserRating.create(rating: skill_rate,user_skill_id: skill_found, mission_id: params[:mesa_id])
				end
				
			end
		end
		# Add notes
                if (params[:notes])
			UserMission.where(user_id: params[:user_id], mission_id: params[:mesa_id]).take.update_attribute(:notes, params[:notes])
		end
		
  end

   def get_mesa_rating(mesa_id)
       skills = self.skills
       skill_array = Skill.get_skill_rating(skills,mesa_id,self.id) if skills
       added_tags = self.added_tags
       tag_array = AddedTag.get_tag_set added_tags if added_tags
       notes = self.user_missions.where(mission_id: mesa_id).take.notes
       {:profile =>{:id => self.id,:name=>self.name,:profile_pic => self.profile_pic.url.to_s}, :added_tags => tag_array,:notes => notes, :skills=> skill_array}
  end


  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  
end
