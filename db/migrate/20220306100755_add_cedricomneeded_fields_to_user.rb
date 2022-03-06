class AddCedricomneededFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :type_of_entity, :string
    add_column :users, :legal_registration_city, :string
    add_column :users, :registration_number, :string
    add_column :users, :address_street, :string
    add_column :users, :address_zip_code, :string
    add_column :users, :address_city, :string
  end
end
