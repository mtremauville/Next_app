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

ActiveRecord::Schema[8.1].define(version: 2026_08_11_170203) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "episode_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "episode_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "watched_at", null: false
    t.index ["episode_id"], name: "index_episode_views_on_episode_id"
    t.index ["user_id", "episode_id"], name: "index_episode_views_on_user_id_and_episode_id", unique: true
    t.index ["user_id"], name: "index_episode_views_on_user_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "number", null: false
    t.bigint "season_id", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "number"], name: "index_episodes_on_season_id_and_number", unique: true
    t.index ["season_id"], name: "index_episodes_on_season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.bigint "title_id", null: false
    t.datetime "updated_at", null: false
    t.index ["title_id", "number"], name: "index_seasons_on_title_id_and_number", unique: true
    t.index ["title_id"], name: "index_seasons_on_title_id"
  end

  create_table "titles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.string "name", null: false
    t.text "overview"
    t.string "poster_path"
    t.date "release_date"
    t.integer "tmdb_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tmdb_id"], name: "index_titles_on_tmdb_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "watchlist_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.bigint "title_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["title_id"], name: "index_watchlist_entries_on_title_id"
    t.index ["user_id", "title_id"], name: "index_watchlist_entries_on_user_id_and_title_id", unique: true
    t.index ["user_id"], name: "index_watchlist_entries_on_user_id"
  end

  add_foreign_key "episode_views", "episodes"
  add_foreign_key "episode_views", "users"
  add_foreign_key "episodes", "seasons"
  add_foreign_key "seasons", "titles"
  add_foreign_key "watchlist_entries", "titles"
  add_foreign_key "watchlist_entries", "users"
end
