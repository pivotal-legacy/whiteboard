class AddIpAddressesToStandups < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :ip_addresses_string, :text
  end
end
