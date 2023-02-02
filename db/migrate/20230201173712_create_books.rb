class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title, nil: false
      t.references :author, nil: false

      t.timestamps
    end
  end
end
