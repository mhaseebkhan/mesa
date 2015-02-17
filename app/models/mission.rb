class Mission < ActiveRecord::Base
 has_many  :users, :through => :user_missions
 has_many :user_missions, :dependent => :destroy 
 has_many :mesa_chairs 
 has_many  :added_tags
 scope :others_mesa, -> (user_id) { where('owner_id = ?',user_id)}
 def self.exists? id
	self.find_by_id(id)
 end

 def get_details 
	to_date = self.to_date.to_date if self.to_date
	from_date = self.from_date.to_date if self.from_date
	{id: self.id, title: self.title, brief: self.brief,shared_motivation: self.shared_motivation, build_intent: self.build_intent, from_date: from_date, to_date: to_date ,time: self.time, place: self.place, invites_out: self.invites_out}
 end

 def get_mission_users 
	users=Array.new
 	mission_users = self.users.where( user_missions:{ invitation_status: ACCEPTED_MESA_INVITATION})
	#mission_users.to_a.delete_if{|user| user.id == self.owner_id}
	mission_users.each do |user|
		users<< user.get_primary_info 
	end
	users
 end

 def get_mission_leader mission_users
	mission_leader = nil
 	 mission_users.each_with_index do |user,i|
		mission_leader = mission_users.to_a.delete_at(i) if !user.roles.first.nil? && user.roles.first.id == ROLE_LEADER 
        end
        mission_leader
 end
 
 def get_mission_owner 
	mission_owner = User.select('id','name','profile_pic','email').where(id: self.owner_id).take
 end

 def get_chairs
	chairs = MesaChair.where(mission_id: self.id).order('mesa_chairs.order ASC');
	chairs_hash_array = Array.new;
	chairs.each do |chair|
		chairs_hash = Hash.new
		chair_users_array =Array.new;
		chairs_hash = {id: chair.id, order: chair.order, mesa_id: chair.mission_id, title: chair.title }
		chair_users = chair.mesa_chair_users
		unless chair_users.empty?
			chair_users.each do |chair_user|
				user = User.exists? chair_user.user_id
				chair_users_array << user.get_primary_info if user
			end
		chairs_hash[:user_array] = chair_users_array
		end
 		chairs_hash_array << chairs_hash
	end
	chairs_hash_array 
 end

  def mesa_when
	"#{self.from_date.to_date} - #{self.to_date.to_date},#{self.time}"
  end

  def set_status(status)
	if  status == MESA_IS_CREATED 
		self.update_attributes(status:false, is_authorized: false)
	elsif  status == MESA_IS_AUTHORIZED 
		self.update_attributes(status:false, is_authorized: true)
	elsif  status == MESA_IS_STARTED 
		self.update_attributes(status:true, is_authorized: true)
	elsif  status == MESA_IS_COMPLETED 
		self.update_attributes(status:true, is_authorized: false)
	else
		self.update_attributes(status:false, is_authorized: false)
	end
	
  end
 
  def get_status
	if  self.status==false && self.is_authorized==false
		MESA_IS_CREATED
	elsif  self.status==false && self.is_authorized==true
		MESA_IS_AUTHORIZED
	elsif  self.status==true && self.is_authorized==true
		MESA_IS_STARTED
	elsif  self.status==true && self.is_authorized==false
		MESA_IS_COMPLETED
	else
		MESA_IS_CREATED
	end
  end

 def set_all_invites_out
	self.update_attribute(:invites_out, Time.now.utc)
 end

 def get_all_invites_out
	self.invites_out
 end


end
