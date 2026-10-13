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

ActiveRecord::Schema[8.1].define(version: 2026_10_13_180153) do
  create_table "entries", force: :cascade do |t|
    t.string "title", null: false
    t.integer "status", default: 0, null: false
    t.integer "rating"
    t.string "platform"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "playlist_id"
    t.integer "tmdb_id"
    t.string "media_type"
    t.string "poster_path"
    t.string "year"
    t.text "overview"
    t.datetime "watched_at"
    t.integer "runtime_minutes"
    t.string "genres"
    t.integer "episodes_total"
    t.index ["playlist_id"], name: "index_entries_on_playlist_id"
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "episode_progresses", force: :cascade do |t|
    t.integer "entry_id", null: false
    t.integer "season_number", null: false
    t.integer "episode_number", null: false
    t.integer "status", default: 0, null: false
    t.integer "runtime_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id", "season_number", "episode_number"], name: "index_episode_progresses_on_episode", unique: true
    t.index ["entry_id"], name: "index_episode_progresses_on_entry_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "entries", "playlists"
  add_foreign_key "entries", "users"
  add_foreign_key "episode_progresses", "entries"
  add_foreign_key "playlists", "users"
end
