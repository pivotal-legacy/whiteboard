class ChangeImageFolderToImageUrls < ActiveRecord::Migration
  def up
    rename_column :standups, :image_folder, :image_urls
    change_column :standups, :image_urls, :text
  end

  def down
    rename_column :standups, :image_urls, :image_folder
    change_column :standups, :image_folder, :string
  end
end
