class TextSource < ApplicationRecord
  has_many :articles

  def scrape
    mdule = "#{self.name}Scraper"
    mdule.constantize.scrape(self)
  end

  def scraper_object
    mdule = "#{self.name}Scraper"
    mdule.constantize
  end
end
