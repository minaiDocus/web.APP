class AddJedeclareUserAndEncryptedJedeclarePasswordToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :jedeclare_user, :string
    add_column :organizations, :encrypted_jedeclare_password, :string
  end
end
