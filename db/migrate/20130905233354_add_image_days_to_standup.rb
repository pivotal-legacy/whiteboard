class AddImageDaysToStandup < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :image_days, :string
  end
end
