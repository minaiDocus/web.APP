class CreateBannerImages < ActiveRecord::Migration[5.2]
  def change
    create_table :banner_images do |t|
      t.string :name
      t.text :path
      t.boolean :is_used, default: false

      t.timestamps

    end
  end
end
