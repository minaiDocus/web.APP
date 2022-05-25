class AddInvoiceCreatedCustumerColumnToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :invoice_created_customer, :boolean, default: false
  end
end
