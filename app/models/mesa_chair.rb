class MesaChair < ActiveRecord::Base
belongs_to :user_mission
belongs_to :mission
has_many :mesa_chair_users,:dependent => :destroy 
end
