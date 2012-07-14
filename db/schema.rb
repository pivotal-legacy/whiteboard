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

ActiveRecord::Schema.define(:version => 20120714062144) do

  create_table "items", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.string   "kind"
    t.integer  "post_id"
    t.boolean  "public",      :default => false
    t.boolean  "bumped",      :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "standup_id"
  end

  create_table "posts", :force => true do |t|
    t.text     "title"
    t.boolean  "sent"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.datetime "sent_at"
    t.string   "from",       :default => "Standup Blogger"
    t.datetime "blogged_at"
    t.boolean  "archived",   :default => false
    t.integer  "standup_id"
  end

  create_table "standups", :force => true do |t|
    t.string   "title"
    t.string   "subject_prefix"
    t.string   "to_address"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
