class AddColumnToPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :user_packages, :is_active, :boolean, default: true, null: false
  end
end
