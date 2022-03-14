class CreatePackage < ActiveRecord::Migration[5.2]
  def change
    create_table :user_packages do |t|
      t.timestamps null: false

      t.string  :name, null: false
      t.integer :period, null: false

      t.boolean :preassignment_active, default: true
      t.boolean :mail_active, default: true
      t.boolean :bank_active, default: false
      t.boolean :upload_active, default: true
      t.boolean :scan_active, default: true
      t.integer :commitment_start_period, default: nil
      t.integer :commitment_end_period, default: nil
      t.integer :version, default: 1

      t.integer :user_id, null: false
    end

    add_index :user_packages, :name
    add_index :user_packages, :period
    add_index :user_packages, :version
    add_index :user_packages, :user_id
  end
end
