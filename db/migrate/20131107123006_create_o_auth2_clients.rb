class CreateOAuth2Clients < ActiveRecord::Migration
  def change
    create_table :o_auth_clients do |t|
      t.string :identifier
      t.string :secret
      t.text :redirect_uri
      t.boolean :official
      t.string :name

      t.timestamps
    end
    add_index :o_auth_clients, ["identifier"], :unique => true
    add_index :o_auth_clients, ["name"], :unique => true
  end
end
