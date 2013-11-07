# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131107124713) do

  create_table "o_auth_access_tokens", force: true do |t|
    t.integer  "user_id"
    t.integer  "o_auth_client_id"
    t.integer  "o_auth_refresh_token_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "o_auth_access_tokens", ["expires_at"], name: "index_o_auth_access_tokens_on_expires_at"
  add_index "o_auth_access_tokens", ["o_auth_client_id"], name: "index_o_auth_access_tokens_on_o_auth_client_id"
  add_index "o_auth_access_tokens", ["token"], name: "index_o_auth_access_tokens_on_token", unique: true
  add_index "o_auth_access_tokens", ["user_id"], name: "index_o_auth_access_tokens_on_user_id"

  create_table "o_auth_authorization_codes", force: true do |t|
    t.integer  "user_id"
    t.integer  "o_auth_client_id"
    t.string   "token"
    t.text     "redirect_uri"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "o_auth_authorization_codes", ["o_auth_client_id"], name: "index_o_auth_authorization_codes_on_o_auth_client_id"
  add_index "o_auth_authorization_codes", ["token"], name: "index_o_auth_authorization_codes_on_token", unique: true
  add_index "o_auth_authorization_codes", ["user_id"], name: "index_o_auth_authorization_codes_on_user_id"

  create_table "o_auth_clients", force: true do |t|
    t.string   "identifier"
    t.string   "secret"
    t.text     "redirect_uri"
    t.boolean  "official"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "o_auth_clients", ["identifier"], name: "index_o_auth_clients_on_identifier", unique: true
  add_index "o_auth_clients", ["name"], name: "index_o_auth_clients_on_name", unique: true

  create_table "o_auth_refresh_tokens", force: true do |t|
    t.integer  "user_id"
    t.integer  "o_auth_client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "o_auth_refresh_tokens", ["expires_at"], name: "index_o_auth_refresh_tokens_on_expires_at"
  add_index "o_auth_refresh_tokens", ["o_auth_client_id"], name: "index_o_auth_refresh_tokens_on_o_auth_client_id"
  add_index "o_auth_refresh_tokens", ["token"], name: "index_o_auth_refresh_tokens_on_token", unique: true
  add_index "o_auth_refresh_tokens", ["user_id"], name: "index_o_auth_refresh_tokens_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
