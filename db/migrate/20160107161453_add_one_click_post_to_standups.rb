class AddOneClickPostToStandups < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :one_click_post, :boolean
  end
end
