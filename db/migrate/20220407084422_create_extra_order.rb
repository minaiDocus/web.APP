class CreateExtraOrder < ActiveRecord::Migration[5.2]
  def change
    create_table :extra_orders do |t|
      t.timestamps null: false

      t.integer :period, null: false

      t.string :name
      t.float  :price, default: 0

      t.string :owner_type
      t.string :owner_id
    end
  end
end
