class AddAuthorToItem < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :author, :string
  end
end
