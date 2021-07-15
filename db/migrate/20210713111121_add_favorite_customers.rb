class AddFavoriteCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :favorite_customers do |t|
      t.text :customer_ids
      t.integer :user_id
      t.timestamps
    end

    add_index :favorite_customers, :user_id
  end
end
