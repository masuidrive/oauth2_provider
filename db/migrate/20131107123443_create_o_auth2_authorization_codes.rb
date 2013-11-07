class CreateOAuth2AuthorizationCodes < ActiveRecord::Migration
  def change
    create_table :o_auth_authorization_codes do |t|
      t.integer :user_id
      t.integer :o_auth_client_id
      t.string :token
      t.text :redirect_uri
      t.timestamp :expires_at

      t.timestamps
    end
    add_index :o_auth_authorization_codes, ["user_id"]
    add_index :o_auth_authorization_codes, ["token"], :unique => true
    add_index :o_auth_authorization_codes, ["o_auth_client_id"]
  end
end
