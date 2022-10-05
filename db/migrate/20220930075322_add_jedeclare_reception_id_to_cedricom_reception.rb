class AddJedeclareReceptionIdToCedricomReception < ActiveRecord::Migration[5.2]
  def change
    add_column :cedricom_receptions, :jedeclare_reception_id, :integer
  end
end
