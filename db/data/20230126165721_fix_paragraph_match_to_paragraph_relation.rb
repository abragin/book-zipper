# frozen_string_literal: true

class FixParagraphMatchToParagraphRelation < ActiveRecord::Migration[6.1]
  def up
    ParagraphMatch.all.each do |pm|
      pm.source_paragraphs = pm.paragraphs_source
      pm.target_paragraphs = pm.paragraphs_target
      pm.save
    end
  end

  def down
    ParagraphMatch.all.each do |pm|
      pm.source_start_position = pm.paragraphs_source.first.position
      pm.source_end_position = pm.paragraphs_source.last.position

      pm.target_start_position = pm.paragraphs_target.first.position
      pm.target_end_position = pm.paragraphs_target.last.position
      pm.save
    end
  end
end
