class AddSomeFields < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :period_v2, :integer, null: false, default: 0
  end
end
