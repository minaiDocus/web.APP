class AddFieldToIbizaSoftware < ActiveRecord::Migration[5.2]
  def change
    add_column :software_ibizas, :token_expires_in, :datetime, after: :encrypted_access_token_2
  end
end
