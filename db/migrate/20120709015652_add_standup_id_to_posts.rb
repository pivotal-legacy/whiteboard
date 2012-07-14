class AddStandupIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :standup_id, :integer
  end
end
