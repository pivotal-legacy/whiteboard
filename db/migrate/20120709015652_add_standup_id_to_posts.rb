class AddStandupIdToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :standup_id, :integer
  end
end
