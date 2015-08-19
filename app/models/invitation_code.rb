class InvitationCode < ActiveRecord::Base
 belongs_to :user
 has_one :invitation

end
