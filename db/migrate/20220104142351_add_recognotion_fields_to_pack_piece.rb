class AddRecognotionFieldsToPackPiece < ActiveRecord::Migration[5.2]
  def change
    add_column :pack_pieces, :detected_third_party_name, :string
    add_column :pack_pieces, :detected_invoice_number, :date
    add_column :pack_pieces, :detected_invoice_date, :date
    add_column :pack_pieces, :detected_invoice_due_date, :date
    add_column :pack_pieces, :detected_invoice_amount_without_taxes, :float
    add_column :pack_pieces, :detected_invoice_taxes_amount, :float
    add_column :pack_pieces, :detected_invoice_amount_with_taxes, :float
  end
end
