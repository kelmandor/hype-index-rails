class Asset < ApplicationRecord
  belongs_to :data_source
  belongs_to :exchange, optional: true
  has_many :data_points

  has_many :article_assets, dependent: :destroy
  has_many :articles, through: :article_assets

  def fetch_historical_data
    self.data_source.scraper_name.constantize.fetch_historical_data(self)
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
        month_start: dt
      }
    end

    dps.each do |dt, dpp|
      if data[dt]
        data[dt].merge!({open: dpp.first.open})
      else
        data[dt] = {
          open: dpp.first.open,
          num_of_articles: 0,
          month_start: dt
        }
      end
    end

    res = []
    data.sort.each do |dt, obj|
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
