class CreateAccountingPlanItemsConterpartAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_plan_items_conterpart_accounts, id: false do |t|
      t.integer "accounting_plan_item_id"
      t.integer "conterpart_account_id"
    end

    add_index :accounting_plan_items_conterpart_accounts, :conterpart_account_id, name: 'index_ca_api_ca_id'
    add_index :accounting_plan_items_conterpart_accounts, :accounting_plan_item_id, name: 'index_ca_api_api_id'
  end
end
