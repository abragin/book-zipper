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

ActiveRecord::Schema.define(version: 2023_01_26_162601) do

  create_table "book_zips", force: :cascade do |t|
    t.integer "ebook_source_id"
    t.integer "ebook_target_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "current_source_paragraph_id"
    t.integer "current_target_paragraph_id"
    t.boolean "in_progress", default: true
    t.index ["current_source_paragraph_id"], name: "index_book_zips_on_current_source_paragraph_id"
    t.index ["current_target_paragraph_id"], name: "index_book_zips_on_current_target_paragraph_id"
    t.index ["ebook_source_id"], name: "index_book_zips_on_ebook_source_id"
    t.index ["ebook_target_id"], name: "index_book_zips_on_ebook_target_id"
  end

  create_table "chapter_zips", force: :cascade do |t|
    t.string "title"
    t.integer "book_zip_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "source_chapter_id"
    t.integer "target_chapter_id"
    t.integer "start_position_source", default: 0
    t.integer "end_position_source"
    t.integer "start_position_target", default: 0
    t.integer "end_position_target"
    t.text "zip_info"
    t.index ["book_zip_id"], name: "index_chapter_zips_on_book_zip_id"
    t.index ["source_chapter_id"], name: "index_chapter_zips_on_source_chapter_id"
    t.index ["target_chapter_id"], name: "index_chapter_zips_on_target_chapter_id"
  end

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
    t.string "content_location"
    t.string "title_tags"
    t.string "content_tag"
    t.string "excluded_content_tag"
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

  create_table "paragraph_matches", force: :cascade do |t|
    t.integer "chapter_zip_id"
    t.integer "position"
    t.integer "source_start_position"
    t.integer "source_end_position"
    t.integer "target_start_position"
    t.integer "target_end_position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chapter_zip_id"], name: "index_paragraph_matches_on_chapter_zip_id"
  end

  create_table "paragraph_matches_source_paragraphs", id: false, force: :cascade do |t|
    t.integer "paragraph_match_id"
    t.integer "paragraph_id"
    t.index ["paragraph_id"], name: "index_paragraph_matches_source_paragraphs_on_paragraph_id"
    t.index ["paragraph_match_id"], name: "index_paragraph_matches_source_paragraphs_on_paragraph_match_id"
  end

  create_table "paragraph_matches_target_paragraphs", id: false, force: :cascade do |t|
    t.integer "paragraph_match_id"
    t.integer "paragraph_id"
    t.index ["paragraph_id"], name: "index_paragraph_matches_target_paragraphs_on_paragraph_id"
    t.index ["paragraph_match_id"], name: "index_paragraph_matches_target_paragraphs_on_paragraph_match_id"
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer "position"
    t.text "content"
    t.integer "chapter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "ignore", default: false
    t.index ["chapter_id"], name: "index_paragraphs_on_chapter_id"
  end

  add_foreign_key "epub_items", "epub_books"
end
