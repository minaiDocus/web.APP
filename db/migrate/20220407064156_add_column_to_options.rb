class AddColumnToOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscription_options, :period, :integer, default: 0, null: false
    add_column :subscription_options, :owner_type, :string
    add_column :subscription_options, :owner_id, :integer

    add_index :subscription_options, :period
    add_index :subscription_options, :owner_type
    add_index :subscription_options, :owner_id
  end
end
