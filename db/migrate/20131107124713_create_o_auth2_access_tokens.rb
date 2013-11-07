class CreateOAuth2AccessTokens < ActiveRecord::Migration
  def change
    create_table :o_auth_access_tokens do |t|
      t.integer :user_id
      t.integer :o_auth_client_id
      t.integer :o_auth_refresh_token_id
      t.string :token
      t.timestamp :expires_at

      t.timestamps
    end
    add_index :o_auth_access_tokens, ["token"], :unique => true
    add_index :o_auth_access_tokens, ["user_id"]
    add_index :o_auth_access_tokens, ["o_auth_client_id"]
    add_index :o_auth_access_tokens, ["expires_at"]
  end
end
