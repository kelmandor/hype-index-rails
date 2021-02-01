class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.references :time_object
      t.references :text_source
      t.string :url
      t.text :headline
      t.timestamps
    end
  end
end
