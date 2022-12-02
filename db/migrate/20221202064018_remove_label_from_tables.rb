class RemoveLabelFromTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :temp_documents, :label
    remove_column :account_book_types, :label
  end
end
