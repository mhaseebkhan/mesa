class MesaChair < ActiveRecord::Base
belongs_to :user_mission
belongs_to :mission
end
