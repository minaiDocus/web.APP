class CreateBillingSimulation < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_simulations do |t|      
      t.timestamps

      t.string  :name, null: false
      t.integer :period, null: false

      t.string  :kind, default: 'normal'
      t.string  :title, default: ''
      t.text    :associated_hash, limit: 510000
      t.boolean :is_frozen, default: false
      t.float   :price, default: 0

      t.string  :owner_type
      t.integer :owner_id
    end

    add_index :billing_simulations, :is_frozen
    add_index :billing_simulations, :name
    add_index :billing_simulations, :kind
    add_index :billing_simulations, :period
    add_index :billing_simulations, :owner_type
    add_index :billing_simulations, :owner_id
  end
end
