class AddPeriodVersionToDataFlow < ActiveRecord::Migration[5.2]
  def change
    add_column :data_flows, :period_version, :integer, default: 0

    add_index :data_flows, :period_version
  end
end
