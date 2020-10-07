class ChangeBlogableToPublicOnItems < ActiveRecord::Migration[4.2]
  def change
    rename_column :items, :blogable, :public
  end
end