class AddChairTitleToMesaChairs < ActiveRecord::Migration
  def change
	 add_column :mesa_chairs, :title, :string
  end

end
