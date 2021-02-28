class AddScraperClassNameToDataSource < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sources, :scraper_name, :string
  end
end
