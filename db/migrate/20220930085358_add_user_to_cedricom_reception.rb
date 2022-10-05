class AddUserToCedricomReception < ActiveRecord::Migration[5.2]
  def change
    add_reference :cedricom_receptions, :user, foreign_key: false, null: true
  end
end
