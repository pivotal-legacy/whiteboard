class AddBlogPostIdToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :blog_post_id, :string
  end
end
