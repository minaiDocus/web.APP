class CreateSoftwareCegidCfes < ActiveRecord::Migration[5.2]
  def change
    create_table :software_cegid_cfes do |t|
      t.boolean :is_used
      t.integer :auto_deliver, default: -1
      t.references :owner, polymorphic: true
      t.string :ftp_server
      t.string :ftp_username
      t.string :ftp_password
      t.string :ftp_inbound_path
      t.string :ftp_outbound_path
      t.string :cegid_identifier

      t.timestamps
    end

    add_index :software_cegid_cfes, :is_used
  end
end
