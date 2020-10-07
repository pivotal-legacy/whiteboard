class AddArchivedToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :archived, :boolean, default: false
  end
end
