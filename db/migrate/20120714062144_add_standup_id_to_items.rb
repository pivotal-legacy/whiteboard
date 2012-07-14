class AddStandupIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :standup_id, :integer
  end
end
