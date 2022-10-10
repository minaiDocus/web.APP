class AddIsForceTd < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_documents, :is_forced, :boolean, default: false
  end
end
