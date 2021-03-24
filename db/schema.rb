# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2015_12_19_135653) do

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

  add_foreign_key "tickets", "users"
end
