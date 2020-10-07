class RemoveOneClickOptionFromStandup < ActiveRecord::Migration[4.2]
  def change
    remove_column :standups, :one_click_post
  end
end
