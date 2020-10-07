class AddStandupIdToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :standup_id, :integer
  end
end
