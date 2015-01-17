class AddUserRefToMesaChairs < ActiveRecord::Migration
  def change
    add_reference :mesa_chairs, :user, index: true
  end
end
