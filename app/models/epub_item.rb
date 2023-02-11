class EpubItem < ApplicationRecord
  include CustomTitleProcessing
  belongs_to :epub_book

  def content_pretty
    xsl =<<XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
    <xsl:copy-of select="."/>
    </xsl:template>
    </xsl:stylesheet>
XSL

    doc = Nokogiri::XML(content)
    xslt = Nokogiri::XSLT(xsl)
    out = xslt.transform(doc)

    out.to_xml
  end

  def parse_content(current_title, current_content)
    ntags = epub_book.title_tags.length
    doc_path =
      if epub_book.content_location.present?
        "/html/body/#{epub_book.content_location}"
       else
        "/html/body"
       end
    doc = Nokogiri::HTML(content).xpath(doc_path)
    doc.children.each do |c|
      content_present = current_content[-1][1].present?
      if update_title(current_title, c, content_present)
        if current_content[-1][1].present?
          current_content.append [title_to_text(current_title), []]
        else
          current_content[-1] = [title_to_text(current_title), []]
        end
      elsif epub_book.content_tag == c.name
        if epub_book.excluded_content_tag.present?
          c.search(epub_book.excluded_content_tag).remove
        end
        content_txt = c.text
        if content_txt.split.size > 0
          current_content[-1][1].append(content_txt)
        end
      end
    end
  end

  def update_title(current_title, tag, content_present)
    if epub_book.custom_update_title.present?
      c_method = epub_book.custom_update_title.to_sym
      if CustomTitleProcessing.public_instance_methods.include?(c_method)
        public_send(c_method, current_title, tag, content_present)
      else
        raise Exception.new("custom_update_title method is not defined")
      end
    else
      update_title_simple(current_title, tag)
    end
  end

  def update_title_simple(current_title, tag)
    if epub_book.title_tags.include?(tag.name)
      tag_i = epub_book.title_tags.index(tag.name)
      current_title[tag.name] = tag.text.strip
      epub_book.title_tags[tag_i+1..].each do |tt|
        current_title[tt] = ""
      end
      true
    end
  end

  def title_to_text(current_title)
    epub_book.title_tags.map do |tt|
      current_title[tt]
    end.filter(&:present?).join('/')
  end

  def body_text
    Nokogiri::HTML(content).xpath('/html/body').text
  end
end
