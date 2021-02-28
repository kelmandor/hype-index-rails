class DataSource < ApplicationRecord
  has_many :assets

  def fetch_all_assets
    self.scraper_name.constantize.fetch_all_assets(self)
  end
end
