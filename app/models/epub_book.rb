class EpubBook < ApplicationRecord
  # TODO add parsing options validation
  serialize :title_tags, Array
  has_many :epub_items,
    -> { order('position') },
    dependent: :destroy
  has_many :book_zips, dependent: :destroy
  has_many :chapters,
    -> { order('chapters.position') },
    dependent: :destroy
  has_many :paragraphs,
    -> {order 'chapters.position, paragraphs.position'},
    through: :chapters
  belongs_to :book
  belongs_to :language

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

  def title
    "#{book.title} (#{language.name})"
  end

  def title_tags_text=(v)
    self.title_tags = v.split(';')
  end

  def title_tags_text
    title_tags.join(';')
  end

  def store_structured
    current_title = Hash.new('')
    current_content = [['', []]]
    items = epub_items.where('position >= ? AND position <= ?',
                             start_position, end_position)
    items.each do |item|
      item.parse_content(current_title, current_content)
    end
    transaction do
      chapters.destroy_all
      current_content.each_with_index do |t_ps, i0|
        c = chapters.build(title: t_ps[0], position: i0)
        t_ps[1].each_with_index do |par_content, i1|
          c.paragraphs.build(position: i1, content: par_content, chapter: c)
        end
        c.save
      end
    end
  end
end
