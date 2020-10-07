class CreateItemsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :items do |t|
      t.text :title
      t.text :description
      t.string :kind
      t.integer :post_id
      t.boolean :blogable
      t.boolean :bumped, default: false

      t.timestamps
    end
  end
end
