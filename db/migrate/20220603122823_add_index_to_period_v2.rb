class AddIndexToPeriodV2 < ActiveRecord::Migration[5.2]
  def change
    add_index :invoices, :period_v2
    add_index :orders, :period_v2
    add_index :period_documents, :period_v2
    add_index :extra_orders, :period
  end
end
