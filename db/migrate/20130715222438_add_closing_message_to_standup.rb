class AddClosingMessageToStandup < ActiveRecord::Migration[4.2]
  def change
    add_column :standups, :closing_message, :string
  end
end
