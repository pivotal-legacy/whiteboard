class AddImageFolderToStandup < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :image_folder, :string
  end
end
