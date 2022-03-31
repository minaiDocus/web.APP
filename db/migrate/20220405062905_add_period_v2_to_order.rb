class AddPeriodV2ToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :period_v2, :integer, default: 0, null: false
  end
end
