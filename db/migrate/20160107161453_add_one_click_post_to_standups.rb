class AddOneClickPostToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :one_click_post, :boolean
  end
end
