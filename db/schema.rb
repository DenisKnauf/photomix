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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120724213209) do

  create_table "albums", :force => true do |t|
    t.string   "title",                                                         :null => false
    t.text     "description"
    t.decimal  "rating_average", :precision => 6, :scale => 2, :default => 0.0
    t.string   "url"
    t.boolean  "public"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.text     "path"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.text     "note"
  end

  add_index "albums", ["id"], :name => "index_albums_on_id", :unique => true

  create_table "collection_albums", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "album_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "collection_albums", ["album_id"], :name => "index_collection_albums_on_album_id"
  add_index "collection_albums", ["collection_id"], :name => "index_collection_albums_on_collection_id"

  create_table "collections", :force => true do |t|
    t.string   "title",                                                           :null => false
    t.string   "description"
    t.decimal  "rating_average", :precision => 6, :scale => 2, :default => 0.0
    t.string   "url"
    t.boolean  "public",                                       :default => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  add_index "collections", ["id"], :name => "index_collections_on_id", :unique => true

  create_table "photo_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "photo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "photo_tags", ["photo_id"], :name => "index_photo_tags_on_photo_id"
  add_index "photo_tags", ["tag_id"], :name => "index_photo_tags_on_tag_id"

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "album_id"
    t.decimal  "rating_average", :precision => 6, :scale => 2, :default => 0.0
    t.string   "url"
    t.boolean  "public"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.text     "path"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "attachment"
  end

  add_index "photos", ["album_id"], :name => "index_photos_on_album_id"
  add_index "photos", ["id"], :name => "index_photos_on_id", :unique => true

  create_table "rates", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars",         :null => false
    t.string   "dimension"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "rates", ["rateable_id", "rateable_type"], :name => "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", ["rater_id"], :name => "index_rates_on_rater_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "tags", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tags", ["id"], :name => "index_tags_on_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "first_name"
    t.string   "second_name"
    t.string   "surname"
    t.string   "userpic"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
