namespace :invitation do
  require 'chronic'
  desc "Sharing queued posts"
  task check_invitation_expiry: :environment do
    puts "----Cron Job :: Checking Epired Invitations Start----"
    puts Time.now
    missions = UserMission.where(invitation_status: PENDING_MESA_INVITATION).all
	missions.each do |mission|
		unless mission.mesa_invitation_not_expired
			mission.update_attribute(:invitation_status, EXPIRED_MESA_INVITATION)
		end
	end
    puts "----Cron Job :: Checking Epired Invitations Ends----"
    puts Time.now
  end
end
