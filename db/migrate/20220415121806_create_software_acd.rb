class CreateSoftwareAcd < ActiveRecord::Migration[5.2]
  def change
    create_table :software_acds do |t|
      t.string :code
      t.string :username
      t.string :encrypted_password
      t.references :owner, polymorphic: true
      t.boolean :is_used
      t.boolean :auto_deliver
      t.boolean :is_auto_updating_accounting_plan

      t.timestamps
    end
  end
end
