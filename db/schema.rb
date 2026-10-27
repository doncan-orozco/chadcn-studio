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

ActiveRecord::Schema[8.1].define(version: 2026_10_27_120100) do
  create_table "generations", force: :cascade do |t|
    t.integer "theme_id", null: false
    t.text "prompt", null: false
    t.json "inputs"
    t.string "error_code"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_generations_on_theme_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.json "light", null: false
    t.json "dark", null: false
    t.json "inputs", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_themes_on_slug", unique: true
  end

  add_foreign_key "generations", "themes"
end
