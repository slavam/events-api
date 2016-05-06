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

ActiveRecord::Schema.define(version: 20160506132808) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.datetime "date_start"
    t.datetime "date_end"
    t.string   "picture"
    t.string   "country"
    t.string   "city"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "likings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "photo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "likings", ["photo_id"], name: "index_likings_on_photo_id", using: :btree
  add_index "likings", ["user_id"], name: "index_likings_on_user_id", using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.boolean  "i_am_going"
    t.boolean  "i_was_there"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "participants", ["event_id"], name: "index_participants_on_event_id", using: :btree
  add_index "participants", ["user_id", "event_id"], name: "index_participants_on_user_id_and_event_id", unique: true, using: :btree
  add_index "participants", ["user_id"], name: "index_participants_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "photos", ["event_id"], name: "index_photos_on_event_id", using: :btree
  add_index "photos", ["user_id"], name: "index_photos_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "taggings", ["event_id"], name: "index_taggings_on_event_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "date_of_birth"
    t.string   "picture"
    t.string   "email"
    t.string   "phone"
    t.string   "website"
    t.string   "fb_url"
    t.string   "vk_url"
    t.string   "ok_url"
    t.string   "provider"
    t.string   "uid"
    t.string   "password_digest"
    t.string   "code_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "city"
    t.string   "country"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "likings", "photos"
  add_foreign_key "likings", "users"
  add_foreign_key "photos", "events"
  add_foreign_key "photos", "users"
  add_foreign_key "taggings", "events"
  add_foreign_key "taggings", "tags"
end
