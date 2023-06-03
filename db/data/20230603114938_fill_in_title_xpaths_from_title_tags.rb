# frozen_string_literal: true

class FillInTitleXpathsFromTitleTags < ActiveRecord::Migration[7.0]

  def xpath_from_condition(cond)
    pred = []
    pred.append("@class = '#{cond[:class]}'") if cond[:class]
    pred.append(
      "descendant-or-self::*/text()[starts-with(normalize-space(), '#{cond[:start]}')]"
    ) if cond[:start]
    res = cond[:tag]
    if pred.present?
      res += "[#{pred.join " and "}]"
    end
    res
  end

  def up
    EpubBook.where('title_xpaths is NULL').each do |eb|
      eb.title_xpaths = eb.title_conditions.map do |tc|
        xpath_from_condition tc
      end
      eb.save!
    end
  end

  def down
  end
end
