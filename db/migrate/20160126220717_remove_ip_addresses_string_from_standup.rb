class RemoveIpAddressesStringFromStandup < ActiveRecord::Migration[4.2]
  def change
    remove_column :standups, :ip_addresses_string
  end
end
