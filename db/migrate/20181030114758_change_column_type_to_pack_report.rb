class ChangeColumnTypeToPackReport < ActiveRecord::Migration
  def up
    change_column :pack_reports, :delivery_message, :text, limit: 65535
  end

  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :pack_reports, :delivery_message, :string
  end
end
