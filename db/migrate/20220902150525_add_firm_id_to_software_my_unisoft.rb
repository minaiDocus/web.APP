class AddFirmIdToSoftwareMyUnisoft < ActiveRecord::Migration[5.2]
  def change
    add_column :software_my_unisofts, :firm_id, :integer
  end
end
