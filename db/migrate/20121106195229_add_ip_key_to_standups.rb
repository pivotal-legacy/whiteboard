class AddIpKeyToStandups < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :ip_key, :string
  end
end
