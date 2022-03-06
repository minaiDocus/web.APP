class AddCedricomNameToOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :cedricom_name, :string
  end
end
