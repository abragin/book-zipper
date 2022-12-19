class AddIgnoreFlagToParagraphs < ActiveRecord::Migration[6.1]
  def change
    change_table :paragraphs do |t|
      t.boolean :ignore, default: false, nil: false
    end
  end
end
