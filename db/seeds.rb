# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

hsh = {
  url: 'https://coinmarketcap.com/all/views/all/',
  name: 'CoinMarketCap',
  scraper_name: 'CmcScraper'
}
DataSource.create(hsh)
hsh = {
  url: 'https://financialmodelingprep.com',
  name: 'Financial Modeling Prep',
  scraper_name: 'FmpFunctions'
}
DataSource.create(hsh)

cds = DataSource.last
cds.fetch_all_assets # this will populate CryptoCoin s + their historical data (CryptoDataPoint s)


tss = [{
    name: 'CoinDesk',
    url: 'https://www.coindesk.com/sitemap_index.xml'
  },
  {
    name: 'Wsj',
    url: 'https://www.wsj.com/news/archive/^yyyy^/^mm^/^dd^'
  },
  {
    name: 'MotleyFool',
    url: 'https://www.fool.com/sitemap/YYYY/MM'
  }
]

tss.each do |ts|
  TextSource.find_or_create_by(ts)
end


# migrate all time_objects to the time fields in
# articles:
aa = Article.all.includes(:time_object)
aa.each{|a| MigrateTimeToArticleWorker.perform_async(a.id)}
# res = aa.map do |a|
#   begin
#     a.datetime = a.time_object.datetime
#     a.timestamp = a.time_object.timestamp
#     a.save
#   rescue
#     nil
#   end
# end

# migrate all time_objects to the time fields in
# data_points:
# dps = DataPoint.all.includes(:time_object)
dps = DataPoint.where(datetime: nil)
dps.each{|dp| MigrateTimeToDatePointWorker.perform_async(dp.id)}
# res = dps.map do |dp|
#   begin
#     dp.datetime = dp.time_object.datetime
#     dp.timestamp = dp.time_object.timestamp
#     dp.save
#   rescue
#     nil
#   end
# end

