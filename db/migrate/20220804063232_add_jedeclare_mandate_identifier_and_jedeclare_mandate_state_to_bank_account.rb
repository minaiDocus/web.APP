class AddJedeclareMandateIdentifierAndJedeclareMandateStateToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :jedeclare_mandate_identifier, :string
    add_column :bank_accounts, :jedeclare_mandate_state, :string
  end
end
