class DataSource < ApplicationRecord
  has_many :assets

  def fetch_all_coins
    data = self.scrape
    self.save_scraped_data(data)
  end

  def scrape
    page = Scrape.raw(self.url)
    rows = page.css('.cmc-table-row')

    data = rows[1..-1].map do |row|
      puts row.text
      coin_hash = {
        name: row.css('.cmc-table__column-name').text,
        url: 'https://coinmarketcap.com' + row.css('a').attr('href').value,
        symbol: row.css('.cmc-table__cell--left').last.text
      }
      coin_hash
    end

    data
  end

  def save_scraped_data(data)
    data.map do |drow|
      coin = self.assets.find_or_initialize_by(drow)

      coin.save
    end
  end
end
