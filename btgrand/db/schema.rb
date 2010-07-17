# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100509141134) do

  create_table "customers", :force => true do |t|
    t.string   "identity_number"
    t.string   "name"
    t.string   "sname"
    t.string   "nickname"
    t.string   "company"
    t.string   "address_home"
    t.string   "address_work"
    t.string   "phone"
    t.string   "phone_work"
    t.string   "picture"
    t.string   "remark"
    t.string   "vehicle"
    t.decimal  "last_price",      :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paylists", :force => true do |t|
    t.integer  "transac_id"
    t.string   "detail"
    t.integer  "ptype"
    t.decimal  "price",           :precision => 8, :scale => 2, :default => 0.0
    t.datetime "room_price_date"
    t.boolean  "ispay"
    t.boolean  "iscancel"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transacs", :force => true do |t|
    t.integer  "room_no"
    t.datetime "checkin"
    t.datetime "checkout"
    t.integer  "customer_id"
    t.string   "customer_name"
    t.string   "customer_phone"
    t.boolean  "isactive"
    t.boolean  "iscancel"
    t.integer  "room_hist_id"
    t.string   "remark"
    t.decimal  "deposit",        :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "price",          :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "balance",        :precision => 8, :scale => 2, :default => 0.0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
