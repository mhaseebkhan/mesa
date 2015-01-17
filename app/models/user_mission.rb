class UserMission < ActiveRecord::Base
 belongs_to :user
 belongs_to :mission
 has_many :mesa_chairs
 def self.exists?(user_id,mesa_id)
        mesa_invitation= nil
	if ((User.exists? user_id) && (Mission.exists? mesa_id))
		mesa_invitation = UserMission.where(user_id: user_id, mission_id: mesa_id).exists? ? nil : true
        end
        mesa_invitation
 end

  #Check if mesa invite has passed 18 hours
  def mesa_invitation_not_expired
	if  self.invitation_time.to_date == Time.now.utc.to_date - 1
		Time.now.utc.hour - self.invitation_time.hour >= 6 ?  false : true
	elsif  self.invitation_time.to_date < Time.now.utc.to_date - 1
		false
        else
		true
	end
  end
end
