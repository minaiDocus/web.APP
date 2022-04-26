class CreateConterpartAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :conterpart_accounts do |t|
      t.datetime "created_at"
      t.datetime "updated_at"

      t.string "name"
      t.string "number"
      t.string "kind"
      t.integer "user_id"
      t.integer "accounting_plan_id"
    end

    add_index :conterpart_accounts, :number
    add_index :conterpart_accounts, :user_id
    add_index :conterpart_accounts, :accounting_plan_id
  end
end
