class UnconciousUser < ActiveRecord::Base
  mount_uploader :profile_pic, ImageUploader

 
  def self.exists? id
	UnconciousUser.find_by_id(id)
  end

  def get_primary_info 
      {:id => self.id, :name=>self.name, :profile_pic => self.profile_pic.url.to_s, :role => ROLE_HARDINPUT }
  end
 
  def role? 
	ROLE_HARDINPUT
  end

 def get_profile
	
	{:profile =>{:id => self.id,:name=>self.name,:email=> self.email,:profile_pic => self.profile_pic.url.to_s,:city => self.city, :languages=>self.languages,:working_at => self.working_at,:skills=> self.skills,:tags => self.tags,:passions => self.passions,:role => ROLE_HARDINPUT}}
 end

end
