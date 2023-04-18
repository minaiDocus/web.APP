class AddStatementFieldsToPackPiece < ActiveRecord::Migration[5.2]
  def change
    add_column :pack_pieces, :detected_bank, :string
    add_column :pack_pieces, :starting_balance, :float
    add_column :pack_pieces, :ending_balance, :float
    add_column :pack_pieces, :total_credit, :float
    add_column :pack_pieces, :total_debit, :float
    add_column :pack_pieces, :detected_account_number, :string
  end
end
