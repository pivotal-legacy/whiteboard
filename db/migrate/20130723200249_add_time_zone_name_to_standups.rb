class AddTimeZoneNameToStandups < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :time_zone_name, :string, null: false, default: 'Eastern Time (US & Canada)'
  end
end
