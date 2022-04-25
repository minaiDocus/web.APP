class AddJournalSizeToPackage < ActiveRecord::Migration[5.2]
  def change
    add_column :user_packages, :journal_size, :integer, default: 5, null: false
  end
end
