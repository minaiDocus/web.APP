class AddCedricomFieldsToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :cedricom_mandate_identifier, :string
    add_column :bank_accounts, :bic, :string
    add_column :bank_accounts, :currency_iso_code, :string
    add_column :bank_accounts, :cedricom_mandate_state, :string

    add_index :bank_accounts, :cedricom_mandate_identifier
  end
end
