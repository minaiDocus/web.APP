class CreateBillings < ActiveRecord::Migration[5.2]
  def change
    create_table :billings do |t|
      t.timestamps null: false

      t.string  :name, null: false
      t.integer :period, null: false

      t.string  :kind, default: 'normal'
      t.string  :title, default: ''
      t.text    :associated_hash, default: :nil, limit: 510000
      t.boolean :is_frozen, default: false
      t.float   :price, default: 0

      t.string  :owner_type
      t.integer :owner_id
    end

    add_index :billings, :is_frozen
    add_index :billings, :name
    add_index :billings, :kind
    add_index :billings, :period
    add_index :billings, :owner_type
    add_index :billings, :owner_id
  end
end
