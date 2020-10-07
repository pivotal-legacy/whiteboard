class RemoveIpKeyFromStandups < ActiveRecord::Migration[4.2]
  def up
    remove_column :standups, :ip_key
  end

  def down
    add_column :standups, :ip_key, :string
  end
end
