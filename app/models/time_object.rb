class TimeObject < ApplicationRecord
  has_many :articles
  has_many :data_points
  def self.init_all_times(date_string = '2013-01-01')
    start_time = DateTime.parse(date_string)
    current_time = start_time
    while current_time < DateTime.now
      time_to_object(current_time)
      current_time += 1.minute
    end
  end

  def self.time_to_object(tm)
    ts = tm.to_i
    obj = {
      datetime: tm,
      timestamp: ts
    }
    self.find_or_create_by(obj)
  end

  def self.serve_data
    where(datetime: [(DateTime.now-13.months)..DateTime.now])
    .includes(articles: :assets).order(:datetime).group_by(&:by_week).map do |k,v|
    # .includes(articles: :assets).order(:datetime).group_by(&:by_month).map do |k,v|
    # .includes(articles: :assets).order(:datetime).group_by(&:by_date).map do |k,v|
      article_counts = v.map do |t|
        t.articles.size
      end.sum

      agg_asset_mentions = v.inject({}) do |res, t|
        t.articles.each do |a|
          a.assets.each do |asst|
            res[asst.symbol] = 0 unless res[asst.symbol]
            res[asst.symbol] += 1
          end
        end
        res
      end

      {
        month_start: k,
        num_of_articles: article_counts,
        asset_mentions: agg_asset_mentions
      }
    end
  end

  def self.serve_csv
    ['date', 'articles']
    serve_data.to_csv
  end

  def by_date
    datetime.to_date.to_s(:db)
  end

  def by_week
    datetime.beginning_of_week.to_date.to_s(:db)
  end

  def by_month
    datetime.beginning_of_month.to_date.to_s(:db)
  end
end
