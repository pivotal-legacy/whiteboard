class AddSentAtToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :sent_at, :timestamp
  end
end
