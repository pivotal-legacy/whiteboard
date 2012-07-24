class AddDateToItems < ActiveRecord::Migration
  def change
    add_column :items, :date, :date
  end
end
