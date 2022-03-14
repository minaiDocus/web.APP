class CreateDataFlow < ActiveRecord::Migration[5.2]
  def change
    create_table :data_flows do |t|
      t.timestamps null: false

      t.integer :period, null: false
      t.integer :pieces, default: 0
      t.integer :operations, default: 0
      t.integer :compta_pieces, default: 0
      t.integer :compta_operations, default: 0

      t.integer :user_id, null: false
    end

    add_index :data_flows, :period
    add_index :data_flows, :user_id
  end
end
