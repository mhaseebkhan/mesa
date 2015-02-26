namespace :invitation do
  require 'chronic'
  require 'date'
   require 'parse-ruby-client'
  desc "Sharing queued posts"
  task check_invitation_expiry: :environment do
    puts "----Cron Job :: Checking Epired Invitations Start----"
    puts Time.now
    missions = UserMission.where(invitation_status: PENDING_MESA_INVITATION).all
	missions.each do |mission|
		unless mission.mesa_invitation_not_expired
			mission.update_attribute(:invitation_status, EXPIRED_MESA_INVITATION)
			mission.allocate_time_slot_to_next_user	
			puts "<<<<<<<<<<<<<<<<<<<Expired invitaion>>>>>>>>>>>>>>>>>>>>>"
			puts mission.id
		end
	end
    puts "----Cron Job :: Checking Epired Invitations Ends----"
    puts Time.now
  end

 task allocate_curator_codes: :environment do
    puts "----Cron Job :: Allocating curator codes Start----"
    puts Time.now
    curator_codes = CuratorCode.all
	curator_codes.each do |curator_code|
		unless curator_code.code_frequency == 0
			last_code_date = curator_code.last_code_time.to_date
			code_frequency = (curator_code.code_frequency).to_i
			no_of_codes = curator_code.no_of_codes
			if code_frequency.months.ago.to_date >= last_code_date
				user = User.find(curator_code.user_id)
			        no_of_codes.times do user.generate_curator_code end
			end
		end
	end
    puts "----Cron Job ::Allocating curator Ends----"
    puts Time.now
  end
end
