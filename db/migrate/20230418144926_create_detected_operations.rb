class CreateDetectedOperations < ActiveRecord::Migration[5.2]
  def change
    create_table :detected_operations do |t|
      t.text :label
      t.float :amount
      t.date :date
      t.references :pack_piece

      t.timestamps
    end
  end
end
