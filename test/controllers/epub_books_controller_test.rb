require "test_helper"

class EpubBooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @epub_book = epub_books(:testepubbook)
  end

  test "should get new" do
    get new_epub_book_url
    assert_response :success
  end

  test "should create epub book" do
    ebook_file = fixture_file_upload('simple_book.epub', 'application/epub')

    assert_difference('EpubBook.count') do
      post epub_books_url, params: {epub_book: {
        book_id: books(:romeo_and_juliet).id,
        language_id: languages(:ger).id,
        file: ebook_file }}
    end
    assert_redirected_to epub_book_url(EpubBook.last)
  end

  test "should update epub book" do
    assert_not_equal books(:romeo_and_juliet).id, @epub_book.book_id
    assert_not_equal languages(:rus).id, @epub_book.language_id
    patch epub_book_url(@epub_book), params: {
      epub_book: { book_id: books(:romeo_and_juliet).id,
                   language_id: languages(:rus).id
    }}
    assert_redirected_to epub_book_url(@epub_book)
    saved_ebook = EpubBook.find(@epub_book.id)
    assert_equal books(:romeo_and_juliet).id, saved_ebook.book_id
    assert_equal languages(:rus).id, saved_ebook.language_id
  end
end
