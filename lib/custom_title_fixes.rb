module CustomTitleFixes
  def fix_mtteol_title(ebook_id)
    def title_predicate(node)
      node.children.present? &&
        node.children[0].name == 'b' &&
        !(node.children[0].text =~ /[a-z]/)
    end

    def update_node(node)
      txt = node.text.strip
      new_node = Nokogiri::XML::DocumentFragment.parse(
        "<h2>#{txt}</h2>").children[0]
      node.replace(new_node)
    end

    book = EpubBook.find(ebook_id)
    book.epub_items.each do |ea|
      doc = Nokogiri::HTML(ea.content)
      doc.xpath('/html/body').children.each do |c|
        if title_predicate(c)
          update_node(c)
        end
      end
      ea.update_attribute(:content, doc.to_xml)
    end
  end
end
