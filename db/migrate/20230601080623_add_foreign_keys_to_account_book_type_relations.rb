class AddForeignKeysToAccountBookTypeRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :packs, :account_book_type_id, :integer
    add_column :operations, :account_book_type_id, :integer
    add_column :temp_packs, :account_book_type_id, :integer
    add_column :temp_documents, :account_book_type_id, :integer
    add_column :pieces, :account_book_type_id, :integer
    add_column :reports, :account_book_type_id, :integer
    add_column :preseizures, :account_book_type_id, :integer

    add_index :packs, :account_book_type_id
    add_index :operations, :account_book_type_id
    add_index :temp_packs, :account_book_type_id
    add_index :temp_documents, :account_book_type_id
    add_index :pieces, :account_book_type_id
    add_index :reports, :account_book_type_id
    add_index :preseizures, :account_book_type_id
  end
end
