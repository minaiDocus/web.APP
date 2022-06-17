class AddColumnsToBannerImages < ActiveRecord::Migration[5.2]
  def change
    add_column :banner_images, :width, :integer, default: 272
    add_column :banner_images, :height, :integer, default: 120
    add_column :banner_images, :pos_x, :integer, default: 1
    add_column :banner_images, :pos_y, :integer, default: 142
    add_column :banner_images, :align, :string, default: ":center"
  end
end
