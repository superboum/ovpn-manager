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

ActiveRecord::Schema.define(version: 20151219135653) do

  create_table "tickets", force: :cascade do |t|
    t.integer "amount"
    t.string "payment_method"
    t.integer "user"
    t.datetime "paid_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user"], name: "index_tickets_on_user"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password"
    t.string "phone"
    t.string "address"
    t.integer "role"
    t.string "nationality"
    t.integer "gender"
    t.string "token"
    t.string "certificate_id"
    t.datetime "expire_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "birth"
  end

end
