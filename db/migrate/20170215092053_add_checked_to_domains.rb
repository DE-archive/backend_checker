class AddCheckedToDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :domains, :checked, :boolean, default: false
  end
end
