class AddCedricomAccountIdentifierAndJedeclareAccountIdentifierToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cedricom_account_identifier, :string
    add_column :users, :jedeclare_account_identifier, :string
  end
end
