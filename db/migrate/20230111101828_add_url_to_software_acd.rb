class AddUrlToSoftwareAcd < ActiveRecord::Migration[5.2]
  def change
    add_column :software_acds, :url, :string
  end
end
