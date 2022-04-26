class AddDefaultToConterpartAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :conterpart_accounts, :is_default, :boolean, default: false
  end
end
