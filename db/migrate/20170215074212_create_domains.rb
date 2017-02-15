class CreateDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :domains do |t|
      t.string :url
      t.integer :rank
      t.string :tld
      t.string :backend

      t.timestamps
    end
  end
end
