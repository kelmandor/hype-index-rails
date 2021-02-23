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
      tm = DateTime.parse(dd['time_open'])
      ts = tm.to_i

      self.data_points.find_or_initialize_by({
        datetime: tm,
        timestamp: ts,
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

  def self.fetch_all_historical
    all.each do |ass|
      GetAssetHistoricalDataWorker.perform_async(ass.id)
    end
  end

  def serve_graph_data
    tos = TimeObject.where(datetime: [(DateTime.now-13.months)..DateTime.now])
    # aa = self.articles.includes(:time_object).where(time_object: tos)
    aa = self.articles.where(time_object: tos)
    dps = self.data_points.where(time_object: tos)


    ts_start = (DateTime.now-13.months).beginning_of_month.to_i
    ts_end = DateTime.now.to_i
    aa = self.articles.where(timestamp: [ts_start..ts_end]).order(:datetime).group_by(&:by_week)
    dps = self.data_points.where(timestamp: [ts_start..ts_end]).order(:datetime).group_by(&:by_week)

    data = {}
    aa.each do |dt, as|
      data[dt] = {
        num_of_articles: as.size,
        month_start: dt,
      }
    end

    dps.each do |dt, dpp|
      if data[dt]
        data[dt].merge!({open: dpp.first.open})
      else
        data[dt] = {
          open: dpp.first.open,
          num_of_articles: 0,
        }
      end
    end

    res = []
    data.each do |dt, obj|
      res << {
        month_start: dt,
        num_of_articles: obj[:num_of_articles],
        open: obj[:open]
      }
    end

    res
  end

  def self.serve_list
    all.order(:id).map do |ast|
      {
        id: ast.id,
        name: ast.name,
        symbol: ast.symbol
      }
    end
  end
end
