class AddColumnToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :display_period_upload, :boolean, default: false
  end
end
