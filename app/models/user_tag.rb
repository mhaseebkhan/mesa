class UserTag < ActiveRecord::Base
 belongs_to :users
 belongs_to :tags
end
