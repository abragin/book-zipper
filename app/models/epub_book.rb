class EpubBook < ApplicationRecord
  has_many :epub_items,
    -> { order('position') },
    dependent: :destroy

  def file=(file)
    self.filename = file.original_filename
    book = GEPUB::Book.parse(file.tempfile)
    self.epub_items = book.items.map.with_index do |k_v, i|
      if k_v[1].media_type == 'application/xhtml+xml'
        EpubItem.new(epub_book: self,
                     position: i,
                     name: k_v[0],
                     content: k_v[1].content
                    )
      end
    end.compact
  end
end
