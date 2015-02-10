class MesaChairUser < ActiveRecord::Base
belongs_to :user
belongs_to :mesa_chair
end
