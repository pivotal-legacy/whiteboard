class CreateStandupsTable < ActiveRecord::Migration
  def change
    create_table :standups do |t|
      t.string :title
      t.string :subject_prefix
      t.string :to_address

      t.timestamps
    end
  end
end
