class Asset < ApplicationRecord
  belongs_to :data_source
  has_many :data_points

  has_many :article_assets, dependent: :destroy
  has_many :articles, through: :article_assets

  def get_cmc_id
    page = Scrape.raw(self.url)
    page.css('img').first.attr('src').split('/').last.split('.').first
  end

  def get_data_url
    cmc_id = get_cmc_id
    start_timestamp = DateTime.parse('2013-01-01').to_i
    self.data_url = "https://web-api.coinmarketcap.com/v1/cryptocurrency/ohlcv/historical?id=#{cmc_id}&convert=USD&time_start=#{start_timestamp}&time_end=#{DateTime.now.to_i}"
    self.save
    self.data_url
  end

  def fetch_historical_data
    get_data_url unless self.data_url
    json = `curl '#{self.data_url}'`
    data = JSON.parse(json)
    data['data']['quotes'].each do |dd|
      time_open = DateTime.parse(dd['time_open'])
      ts = time_open.to_i
      obj = {
        datetime: time_open,
        timestamp: ts
      }
      to = TimeObject.find_or_create_by(obj)
      self.data_points.build({
        time_object: to,
        open: dd['quote']['USD']['open'],
        close: dd['quote']['USD']['close'],
        high: dd['quote']['USD']['high'],
        low: dd['quote']['USD']['low'],
        volume: dd['quote']['USD']['volume'],
        market_cap: dd['quote']['USD']['market_cap']
      })
    end
    self.save
  end
end
