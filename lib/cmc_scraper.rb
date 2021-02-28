module CmcScraper
  def self.fetch_all_assets(ds)
    data = scrape(ds)
    save_scraped_data(ds, data)
  end

  def self.scrape(ds)
    page = Scrape.raw(ds.url)
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

  def self.save_scraped_data(ds, data)
    data.map do |drow|
      coin = ds.assets.find_or_initialize_by(drow)

      coin.save
    end
  end

  def self.fetch_historical_data(ast)
    get_data_url(ast) unless ast.data_url
    json = `curl '#{ast.data_url}'`
    data = JSON.parse(json)
    data['data']['quotes'].each do |dd|
      tm = DateTime.parse(dd['time_open'])
      ts = tm.to_i

      ast.data_points.find_or_initialize_by({
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
    ast.save
  end

  def self.get_cmc_id(ast)
    page = Scrape.raw(ast.url)
    page.css('img').first.attr('src').split('/').last.split('.').first
  end

  def self.get_data_url(ast)
    cmc_id = get_cmc_id(ast)
    start_timestamp = DateTime.parse('2013-01-01').to_i
    ast.data_url = "https://web-api.coinmarketcap.com/v1/cryptocurrency/ohlcv/historical?id=#{cmc_id}&convert=USD&time_start=#{start_timestamp}&time_end=#{DateTime.now.to_i}"
    ast.save
    ast.data_url
  end
end