class AddGeneralAccountAp < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_plans, :general_account_providers, :string
    add_column :accounting_plans, :general_account_customers, :string
  end
end
