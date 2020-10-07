class AddDateToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :date, :date
  end
end
