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

ActiveRecord::Schema.define(version: 2022_11_23_153632) do

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.integer "epub_book_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["epub_book_id"], name: "index_chapters_on_epub_book_id"
  end

  create_table "epub_books", force: :cascade do |t|
    t.string "title"
    t.string "filename"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title_parsing"
    t.string "content_parsing"
    t.string "excluded_content"
    t.integer "start_position"
    t.integer "end_position"
  end

  create_table "epub_items", force: :cascade do |t|
    t.integer "position"
    t.string "name"
    t.text "content"
    t.integer "epub_book_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["epub_book_id"], name: "index_epub_items_on_epub_book_id"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer "position"
    t.text "content"
    t.integer "chapter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chapter_id"], name: "index_paragraphs_on_chapter_id"
  end

  add_foreign_key "epub_items", "epub_books"
end
