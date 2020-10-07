class CreatePostsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.text :title
      t.boolean :sent

      t.timestamps
    end
  end
end
