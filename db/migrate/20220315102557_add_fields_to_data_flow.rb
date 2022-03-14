class AddFieldsToDataFlow < ActiveRecord::Migration[5.2]
  def change
    add_column :data_flows, :bank_excess, :integer, default: 0
    add_column :data_flows, :journal_excess, :integer, default: 0
    add_column :data_flows, :scanned_sheets, :integer, default: 0
  end
end
