class CreateArticleAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :article_assets do |t|
      t.references :article
      t.references :asset
      t.timestamps
    end
  end
end
