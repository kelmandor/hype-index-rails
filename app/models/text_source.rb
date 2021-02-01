class TextSource < ApplicationRecord
  has_many :articles

  def scrape
    mdule = "#{self.name}Scraper"
    mdule.constantize.scrape(self)
  end
end
