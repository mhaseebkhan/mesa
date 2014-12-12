class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  belongs_to :roles
  has_many  :skills, :through => :user_skills
  has_many :skills, :dependent => :destroy  
  has_many  :tags, :through => :user_tags
  has_many :tags, :dependent => :destroy  
  has_many  :missions, :through => :user_missions
  has_many :missions, :dependent => :destroy  
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
 
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  
end
