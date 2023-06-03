class EpubBook < ApplicationRecord
  # TODO add parsing options validation
  serialize :title_xpaths, Array
  has_many :epub_items,
    -> { order('position') },
    dependent: :destroy
  has_many :book_zips_source, inverse_of: :ebook_source,
    class_name: "BookZip", foreign_key: :ebook_source_id,
    dependent: :destroy
  has_many :book_zips_target, inverse_of: :ebook_target,
    class_name: "BookZip", foreign_key: :ebook_target_id,
    dependent: :destroy
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
    self.epub_items = book.spine.itemref_list.map.with_index do |id_ref, idx|
      name = id_ref['idref']
      item = book.items[name]
      if item.media_type == 'application/xhtml+xml'
        EpubItem.new(epub_book: self,
                     position: idx,
                     name: name,
                     content: item.content
                    )
      end
    end.compact
  end

  def matching_tag_position(tag)
    title_conditions.each_with_index do |tc, i|
      class_match = !tc[:class] || (
        tag.attributes['class'] && tag.attributes['class'].value == tc[:class]
      )
      node_text = tag.text.strip
      start_match = !tc[:start] || node_text.starts_with?(tc[:start]
      )
      if (tag.name == tc[:tag]) && class_match && start_match
        return i
      end
    end
    return
  end

  def title
    "#{book.title} (#{language.name})"
  end

  def title_xpaths_text=(v)
    self.title_xpaths = v.split(';')
  end

  def title_xpaths_text
    title_xpaths.join(';')
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
        if c.paragraphs.present?
          c.save
        end
      end
    end
  end
end
