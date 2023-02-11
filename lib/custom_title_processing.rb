module CustomTitleProcessing
  def update_title_the_golden_calf_en(current_title, tag, content_present=false)
    if tag.name == 'p'
      if !(tag.text =~ /[a-z]/)
        if tag.attributes["class"]
          txt = tag.text.strip
          case tag.attributes['class'].value
          when "calibre_16"
            current_title.delete("p.calibre_")
            current_title["p.calibre_16"] = txt
          when "calibre_"
            current_title["p.calibre_"] = txt
          when "calibre_5"
            if !content_present
              if current_title.include? "p.calibre_"
                current_title["p.calibre_"] += " #{txt}"
              else
                current_title["p.calibre_16"] += " #{txt}"
              end
            end
          end
        end
      end
    end
  end
end
