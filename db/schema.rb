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

ActiveRecord::Schema[7.0].define(version: 2023_06_03_131029) do
  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_zips", force: :cascade do |t|
    t.integer "ebook_source_id"
    t.integer "ebook_target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ebook_source_id"], name: "index_book_zips_on_ebook_source_id"
    t.index ["ebook_target_id"], name: "index_book_zips_on_ebook_target_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
  end

  create_table "chapter_zips", force: :cascade do |t|
    t.integer "book_zip_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_chapter_id", null: false
    t.integer "target_chapter_id", null: false
    t.integer "start_position_source", default: 0, null: false
    t.integer "end_position_source", null: false
    t.integer "start_position_target", default: 0, null: false
    t.integer "end_position_target", null: false
    t.text "zip_info"
    t.index ["book_zip_id"], name: "index_chapter_zips_on_book_zip_id"
    t.index ["source_chapter_id"], name: "index_chapter_zips_on_source_chapter_id"
    t.index ["target_chapter_id"], name: "index_chapter_zips_on_target_chapter_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.integer "epub_book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epub_book_id"], name: "index_chapters_on_epub_book_id"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "epub_books", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_location"
    t.string "content_tag"
    t.string "excluded_content_tag"
    t.integer "start_position"
    t.integer "end_position"
    t.integer "book_id", null: false
    t.integer "language_id", null: false
    t.string "custom_update_title", default: ""
    t.string "title_xpaths"
    t.index ["book_id"], name: "index_epub_books_on_book_id"
    t.index ["language_id"], name: "index_epub_books_on_language_id"
  end

  create_table "epub_items", force: :cascade do |t|
    t.integer "position"
    t.string "name"
    t.text "content"
    t.integer "epub_book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epub_book_id"], name: "index_epub_items_on_epub_book_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer "position"
    t.text "content"
    t.integer "chapter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ignore", default: false
    t.index ["chapter_id"], name: "index_paragraphs_on_chapter_id"
  end

  add_foreign_key "epub_items", "epub_books"
end
