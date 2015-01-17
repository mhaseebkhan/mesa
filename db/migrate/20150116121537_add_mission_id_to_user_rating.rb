class AddMissionIdToUserRating < ActiveRecord::Migration
  def change
    add_reference :user_ratings, :mission, index: true
  end
end
