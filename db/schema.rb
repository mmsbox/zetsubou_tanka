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

ActiveRecord::Schema[8.1].define(version: 2026_11_12_080000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "karuta_results", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "level", null: false
    t.integer "player_score", default: 0, null: false
    t.integer "cpu_score", default: 0, null: false
    t.integer "otetsuki", default: 0, null: false
    t.integer "card_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_karuta_results_on_user_id_and_created_at"
  end

  create_table "karuta_rooms", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.bigint "host_id", null: false
    t.bigint "guest_id"
    t.string "status", default: "waiting", null: false
    t.jsonb "cards", default: [], null: false
    t.jsonb "reading_order", default: [], null: false
    t.integer "turn", default: 0, null: false
    t.boolean "turn_open", default: false, null: false
    t.jsonb "missed", default: [], null: false
    t.jsonb "taken", default: {}, null: false
    t.integer "host_score", default: 0, null: false
    t.integer "guest_score", default: 0, null: false
    t.integer "host_otetsuki", default: 0, null: false
    t.integer "guest_otetsuki", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_karuta_rooms_on_code", unique: true
    t.index ["guest_id"], name: "index_karuta_rooms_on_guest_id"
    t.index ["host_id"], name: "index_karuta_rooms_on_host_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "author_name"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "likes_count"
    t.text "tanka"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "parent_id"
    t.string "error_category"
    t.text "ai_advice"
    t.string "error_signature"
    t.index ["parent_id"], name: "index_posts_on_parent_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "karuta_results", "users"
  add_foreign_key "karuta_rooms", "users", column: "guest_id"
  add_foreign_key "karuta_rooms", "users", column: "host_id"
  add_foreign_key "posts", "users"
end
