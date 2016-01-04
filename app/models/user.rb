class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  validates :email, :uniqueness => true
  has_many  :skills, :through => :user_skills
  has_many :user_skills, :dependent => :destroy  
  has_many  :tags, :through => :user_tags
  has_many :user_tags, :dependent => :destroy  
  has_many  :missions, :through => :user_missions
  has_many :user_missions, :dependent => :destroy  
  has_one :invitation,:dependent => :destroy  
  has_many :invitation_codes,:dependent => :destroy  
  has_one :curator_code
  has_many :roles, :through => :user_roles
  has_many :user_roles,:dependent => :destroy  
  has_many :added_tags,:dependent => :destroy  
  has_many :mesa_chair_users,:dependent => :destroy  
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
 
  def build_profile(profile,role)
	   if profile
          #Set user attributes
	  self.update_attributes(name: profile[:name], phone: profile[:phone],city: profile[:city], languages: profile[:languages].to_s,working_at: profile  [:working_at], profile_pic: profile[:profile_pic],passions: profile[:passions].to_s) 
		if (profile[:skills])
			profile[:skills].each do |skill|
				unless skill[:name] == ""
					#skill_found = Skill.find_or_create_by(name: skill[:name])
					skill_found = Skill.where("lower(name) = ?", "#{skill[:name].downcase}").take
					unless skill_found
						skill_found = Skill.create(name: skill[:name])
					end
					UserSkill.create( user_id: self.id, skill_id: skill_found.id, work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded] )
				end
			end
		end
		if (profile[:tags])
			profile[:tags].each do |tag|
				unless tag[:name] == ""
					#tag_found = Tag.find_or_create_by(name: tag[:name])
					tag_found = Tag.where("lower(name) = ?", "#{tag[:name].downcase}").take
					unless tag_found
						tag_found = Tag.create(name: tag[:name])
					end
					UserTag.create( user_id: self.id, tag_id: tag_found.id)
				end
			end
		end
		#For HardInput Users
                if (profile[:created_by])
			self.update_attribute(:created_by, profile[:created_by])	
		end
		#Occupy code
		invitaion_code = InvitationCode.find_by(code_text: profile[:code])
		if invitaion_code
			invitaion_code.update_attribute(:status, TAKEN_INVITATION_STATUS) 
			role = invitaion_code.role_id
			 #Set user role
			UserRole.create(user_id: self.id, role_id: role)
			Invitation.create(invitation_code_id: invitaion_code.id ,user_id: self.id)
		else
			 #Set user role
			UserRole.create(user_id: self.id, role_id: role)
		end
             end
               
                
           
  end

 def update_profile(profile)
	  self.update_attributes(name: profile[:name],email: profile[:email], phone: profile[:phone], city: profile[:city], languages: profile[:languages].to_s,working_at: profile  [:working_at], profile_pic: profile[:profile_pic],passions: profile[:passions].to_s) 
                # this code assumes that skill once added wiill never be deleted in update
		if (profile[:skills])
			profile[:skills].each do |skill|
				new_skill = Skill.find_or_create_by(name: skill[:new_name])
				old_skill = Skill.find_by(name: skill[:name])
				user_skill = UserSkill.find_or_create_by(user_id: self.id, skill_id: old_skill.id)		
				user_skill.update_attributes( work_ref: skill[:work_ref], company: skill[:company], time_spent: skill[:time_spent], founded: skill[:founded],skill_id: new_skill.id )
			end
			
		end
		if (profile[:tags])
			UserTag.where(user_id: self.id).delete_all
			profile[:tags].each do |tag|
				tag_found = Tag.find_or_create_by(name: tag[:name])
				UserTag.find_or_create_by( user_id: self.id, tag_id: tag_found.id)
			end
		end
  end



  def get_profile
       skills = self.skills
       skill_array = Skill.get_skill_set(skills,self.id) if skills
       tags = self.tags
       tag_array = Tag.get_tag_set(tags,self.id) if tags
	
	{:email=> self.email,:profile =>{:id => self.id,:name=>self.name.to_s.titleize,:phone=> self.phone.to_s, :profile_pic =>get_user_img,:city => self.city, :languages=>self.languages,:working_at => self.working_at,:skills=> skill_array, :tags => tag_array,:passions => self.passions,:role =>  self.roles.first.id, favorite: self.favorite }}
  end

  def self.email_exists? email
	User.find_by_email(email)
  end

  def self.exists? id
	User.find_by_id(id)
  end
 
  def role? 
	if self.roles.first.nil?
		#UserRole.create(user_id: self.id, role_id: ROLE_COMMONFLAGGER)
		ROLE_COMMON
	else
		self.roles.first.id
	end
  end

  def get_primary_info 
      {:id => self.id, :name=>self.name.to_s.titleize, :profile_pic => get_user_img, :role => self.roles.first.id, :created_by => self.created_by }
  end

  
  def rate_profile(params)
		#Add new tags
		if (params[:new_tags])
			AddedTag.where(user_id: self.id).delete_all
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
		user_skill_ids = UserSkill.where(user_id: params[:user_id]).pluck(:id)
		existing_user_ratings = UserRating.where(user_skill_id: user_skill_ids, mission_id: params[:mesa_id] )
		if (params[:star_rating])
			params[:star_rating].each do |skill|
				skill_rate = skill.split("_")[0]
				skill_id = skill.split("_")[1]
				skill_found = UserSkill.where(user_id: params[:user_id], skill_id: skill_id).take.id
				rating_found = UserRating.where(user_skill_id: skill_found, mission_id: params[:mesa_id] )
				existing_user_ratings.to_a.delete_if{|existing_user_rating| rating_found == existing_user_rating.user_skill_id }
				unless rating_found.empty?
					rating_found.take.update_attribute(:rating, skill_rate)
				else
					UserRating.create(rating: skill_rate,user_skill_id: skill_found, mission_id: params[:mesa_id])
				end
				
			end
		end
                existing_user_ratings.each do |rate|
			 rate.update_attribute(:rating, 0)
		end
               
		# Add notes
                if (params[:notes])
			UserMission.where(user_id: params[:user_id], mission_id: params[:mesa_id]).take.update_attribute(:notes, params[:notes])
		end
		
  end

   def get_mesa_rating(mesa_id)
       skills = self.skills
       skill_array = Skill.get_skill_rating(skills,mesa_id,self.id) if skills
       added_tags = self.added_tags.where(mission_id: mesa_id)
       tag_array = AddedTag.get_tag_set added_tags if added_tags
       user_mission = self.user_missions.where(mission_id: mesa_id).take
       notes = Array.new
       if user_mission.notes 
	       notes << {:note => user_mission.notes}
       end
       {:profile =>{:id => self.id,:name=>self.name.to_s.titleize,:profile_pic => get_user_img, :working_at => self.working_at, favorite: self.favorite}, :added_tags => tag_array,:notes => notes, :skills=> skill_array}
  end

  def open_codes
	self.invitation_codes.where(status: PENDING_INVITATION_STATUS)
  end 
 
  def taken_codes
	self.invitation_codes.where(status: TAKEN_INVITATION_STATUS)
  end  

  def get_curator_details
	curator = self.get_primary_info 
	curator[:no_of_codes] =0
	curator[:code_frequency] = 0
	if self.curator_code
		curator[:no_of_codes] =  self.curator_code.no_of_codes
		curator[:code_frequency] = self.curator_code.code_frequency
	end
	curator
  end

  def update_curator_details(no_of_codes,code_frequency)
	CuratorCode.find_or_create_by(user_id: self.id).update_attributes(no_of_codes: no_of_codes,code_frequency: code_frequency)
  end
  
  def generate_invitation_code
	code = ''
        loop do
	      code = [*('A'..'Z')].sample(8).join
	      break code unless InvitationCode.where(code_text: code).first
    	end
	InvitationCode.create(code_text: code, user_id: self.id, status: PENDING_INVITATION_STATUS)
  end

  def generate_curator_code
	generate_invitation_code
	CuratorCode.find_or_create_by(user_id: self.id).update_attributes(last_code_time: Time.now.utc)
  end

  def get_user_rating
	skills = self.skills
       skill_array = Skill.get_average_skill_rating(skills,self.id) if skills
       added_tags = self.added_tags
       tag_array = AddedTag.get_tag_set added_tags if added_tags
	notes = Array.new
        self.user_missions.collect{|user_mission| notes << {:note => user_mission.notes, :by => Mission.where(id: user_mission.mission_id).take.get_mission_owner } if user_mission.notes}
	
	 {:profile =>{:id => self.id,:name=>self.name.to_s.titleize,:profile_pic => get_user_img, :working_at => self.working_at, favorite: self.favorite}, :added_tags => tag_array,:notes => notes, :skills=> skill_array}
  end


  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

 def get_user_img
	self.profile_pic.present? ? self.profile_pic.url.to_s : '/assets/user.png'
 end

  
end
