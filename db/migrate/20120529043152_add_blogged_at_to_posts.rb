class AddBloggedAtToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :blogged_at, :timestamp
  end
end
