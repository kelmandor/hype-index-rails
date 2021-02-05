class AddScannedForAssetsToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :scanned_for_assets, :boolean, default: false
  end
end
