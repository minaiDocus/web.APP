class CreateSoftwareCogilog < ActiveRecord::Migration[5.2]
  def change
    create_table :software_cogilogs do |t|
      t.boolean :is_used
      t.integer :auto_deliver, default: -1
      t.integer :owner_id
      t.string :owner_type

      t.timestamp
    end
  end
end
