class AddErrorMessageToDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :domains, :error_message, :string
  end
end
