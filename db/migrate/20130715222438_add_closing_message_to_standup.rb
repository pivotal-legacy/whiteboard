class AddClosingMessageToStandup < ActiveRecord::Migration
  def change
    add_column :standups, :closing_message, :string
  end
end
