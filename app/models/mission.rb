class Mission < ActiveRecord::Base
 has_many  :users, :through => :user_missions
 has_many :user_missions, :dependent => :destroy  
 
 def self.exists? id
	self.find_by_id(id)
 end

 def get_details 
	{id: self.id, title: self.title, brief: self.brief,shared_motivation: self.shared_motivation, build_intent: self.build_intent, from_date: self.from_date, to_date: self.to_date,time: self.time, place: self.place}
 end

 def get_mission_users 
 	mission_users = self.users.select('users.id', 'users.name','users.profile_pic').where( user_missions:{ invitation_status: ACCEPTED_MESA_INVITATION})
 end

 def get_mission_leader mission_users
	mission_leader = nil
 	 mission_users.each_with_index do |user,i|
		mission_leader = mission_users.to_a.delete_at(i) if !user.roles.first.nil? && user.roles.first.id == ROLE_LEADER 
        end
        mission_leader
 end
 
 def get_mission_owner 
	mission_owner = User.select('id','name','profile_pic').where(id: self.owner_id).take
 end

end
