desc "Generate dataset from all ChapterZip-s"

task :generate_dataset, [:author_id] => [:environment] do |task, args|
  if args.author_id
    author = Author.find(args.author_id)
    book_ids = author.books.map(&:id)
    epub_books = EpubBook.where("book_id IN (?)", book_ids)
    epub_book_ids = epub_books.map(&:id)
    book_zips = BookZip.where(
      "ebook_source_id IN (?) AND ebook_target_id IN (?)",
      epub_book_ids, epub_book_ids)
  else
    book_zips = BookZip.all
  end
  res = book_zips.map(&:export_hash)
  File.write('./zip_data_dataset.json', JSON.dump(res))
end
