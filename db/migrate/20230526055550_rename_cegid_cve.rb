class RenameCegidCve < ActiveRecord::Migration[5.2]
  def change
    rename_table :software_cegid_cfes, :software_cegid_cves
  end
end
