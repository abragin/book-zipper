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
    doc_path =
      if epub_book.content_location.present?
        "/html/body/#{epub_book.content_location}"
       else
        "/html/body"
       end
    doc = Nokogiri::HTML(content).xpath(doc_path)
    title_nodes = epub_book.title_xpaths.map do |txp|
      doc.xpath(txp)
    end
    title_and_content_xpath =
      (epub_book.title_xpaths + [epub_book.content_xpath]).join('|')

    doc.xpath(title_and_content_xpath).each do |c|
      content_present = current_content[-1][1].present?
      if update_title(current_title, c, content_present, title_nodes)
        if current_content[-1][1].present?
          current_content.append [title_to_text(current_title), []]
        else
          current_content[-1] = [title_to_text(current_title), []]
        end
      else
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

  def update_title(current_title, tag, content_present, title_nodes)
    if epub_book.custom_update_title.present?
      c_method = epub_book.custom_update_title.to_sym
      if CustomTitleProcessing.public_instance_methods.include?(c_method)
        public_send(c_method, current_title, tag, content_present)
      else
        raise Exception.new("custom_update_title method is not defined")
      end
    else
      title_nodes.each_with_index do |t_nodes, tag_i|
        if t_nodes.include?(tag)
          current_title[epub_book.title_xpaths[tag_i]] = tag.text.strip
          epub_book.title_xpaths[tag_i+1..].each do |tt|
            current_title[tt] = ""
          end
          return true
        end
      end
      false
    end
  end

  def title_to_text(current_title)
    epub_book.title_xpaths.map do |tt|
      current_title[tt]
    end.filter(&:present?).join('/')
  end

  def body_text
    Nokogiri::HTML(content).xpath('/html/body').text
  end
end
