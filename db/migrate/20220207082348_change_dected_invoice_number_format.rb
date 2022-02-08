class ChangeDectedInvoiceNumberFormat < ActiveRecord::Migration[5.2]
  def change
    change_column :pack_pieces, :detected_invoice_number, :string
  end
end
