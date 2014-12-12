class Invitation < ActiveRecord::Base
 belongs_to :users
 has_one :invitation_code, :dependent => :destroy
end
