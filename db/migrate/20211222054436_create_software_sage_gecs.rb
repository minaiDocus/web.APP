class CreateSoftwareSageGecs < ActiveRecord::Migration[5.2]
  def change
    create_table :software_sage_gecs do |t|
      t.string :sage_private_api_uuid
      t.references :owner, polymorphic: true
      t.boolean :is_used
      t.boolean :auto_deliver
      t.boolean :is_auto_updating_accounting_plan

      t.timestamps
    end
  end
end
