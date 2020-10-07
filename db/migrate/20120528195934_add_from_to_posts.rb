class AddFromToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :from, :string, default: 'Standup Blogger'
  end
end
