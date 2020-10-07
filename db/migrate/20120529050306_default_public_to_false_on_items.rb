class DefaultPublicToFalseOnItems < ActiveRecord::Migration[4.2]
  def up
    change_column_default :items, :public, false
  end
end
