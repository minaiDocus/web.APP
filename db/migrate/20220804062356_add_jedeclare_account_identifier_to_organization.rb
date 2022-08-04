class AddJedeclareAccountIdentifierToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :jedeclare_account_identifier, :string
  end
end
