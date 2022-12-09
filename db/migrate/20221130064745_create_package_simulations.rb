class CreatePackageSimulations < ActiveRecord::Migration[5.2]
  def change
    create_table "user_package_simulations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name", null: false
      t.integer "period", null: false
      t.boolean "preassignment_active", default: true
      t.boolean "mail_active", default: true
      t.boolean "bank_active", default: false
      t.boolean "upload_active", default: true
      t.boolean "scan_active", default: true
      t.integer "commitment_start_period"
      t.integer "commitment_end_period"
      t.integer "version", default: 1
      t.integer "user_id", null: false
      t.integer "journal_size", default: 5, null: false
      t.boolean "is_active", default: true, null: false
      t.index ["name"], name: "index_user_packages_simulation_on_name"
      t.index ["period"], name: "index_user_packages_simulation_on_period"
      t.index ["user_id"], name: "index_user_packages_simulation_user_on_id"
      t.index ["version"], name: "index_user_packages_simulation_on_version"
    end
  end
end
