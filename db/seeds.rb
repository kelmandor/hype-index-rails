# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

hsh = {
  url: 'https://coinmarketcap.com/all/views/all/',
  name: 'CoinMarketCap'
}
DataSource.create(hsh)

cds = DataSource.last
cds.fetch_all_coins # this will populate CryptoCoin s + their historical data (CryptoDataPoint s)


tss = [{
  name: 'CoinDesk',
  url: 'https://www.coindesk.com/sitemap_index.xml'
}]

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
dps = DataPoint.all.includes(:time_object)
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

