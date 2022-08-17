class AddLabelToAccountBookType < ActiveRecord::Migration[5.2]
  def change
    add_column :account_book_types, :label, :string, after: :pseudonym
  end
end
