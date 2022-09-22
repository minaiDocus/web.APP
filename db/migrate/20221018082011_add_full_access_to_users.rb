class AddFullAccessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :full_access, :boolean, default: true

    add_index :users, :full_access
  end
end
