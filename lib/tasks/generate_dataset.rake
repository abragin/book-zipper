desc "Generate dataset from all ChapterZip-s"

task :generate_dataset do

  res = BookZip.all.map do |book_zip|
    chapters = book_zip.chapter_zips.map do |cz|
      ps_source = cz.paragraph_matches.flat_map{|pm| pm.source_paragraphs}
      ps_ls = ps_source.map do |p|
        p.content.split().length
      end
      len_total = ps_ls.sum.to_f
      ws1 = ps_ls.map{|l| l/len_total}
      ps_target = cz.paragraph_matches.flat_map{|pm| pm.target_paragraphs}
      ps_ls = ps_target.map do |p|
        p.content.split().length
      end
      len_total = ps_ls.sum.to_f
      ws2 = ps_ls.map{|l| l/len_total}
      source_ids = ps_source.map{|p| p.id}
      mi1 = cz.zip_info['source']['attach_ids'].map do |aid|
        source_ids.find_index(aid)
      end
      target_ids = ps_target.map{|p| p.id}
      mi2 = cz.zip_info['target']['attach_ids'].map do |aid|
        target_ids.find_index(aid)
      end
      {
        title: cz.title,
        source_weights: ws1,
        target_weights: ws2,
        merged_source_idx: mi1,
        merged_target_idx: mi2
      }
    end
    {title: book_zip.title, chapters: chapters}
  end
  File.write('./paragraphs_weights_dataset.json', JSON.dump(res))
end
