module FmpFunctions
  def self.fetch_all_assets(ds)
    data = stocks_list(ds)
    save_data(ds, data)
  end

  def self.run_method(ds, api_str, prms = {})
    prms.merge!(apikey: '04d26577b3608f4b398bf53f3989ce5c')
    qs = prms.map{|k,v| "#{k}=#{v}"}.join('&')
    uri = URI.parse("#{ds.url}#{api_str}?#{qs}")
    request = Net::HTTP::Get.new(uri)
    request["Upgrade-Insecure-Requests"] = "1"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    # response.code
    JSON.parse(response.body)
  end

  def self.stocks_list(ds)
    api_str = '/api/v3/stock/list'
    stocks = run_method(ds, api_str)
    ee = Exchange.all.map{|e| [e.name, e]}.to_h
    stocks.map do |row|
      # exchng = Exchange.find_or_create_by(name: row['exchange'])
      hsh = {
        name: row['name'],
        symbol: row['symbol'],
        exchange: ee[row['exchange']]
      }

      hsh
    end
  end

  def self.save_data(ds, data)
    asts = Asset.all.pluck(:name, :symbol)
    data.map do |drow|
      if !asts.index([drow[:name], drow[:symbol]])
        # coin = ds.assets.find_or_initialize_by(drow)
        coin = ds.assets.create(drow)

        coin.save
      end
    end
  end

  def self.fetch_historical_data(ast)
    from = '2013-01-01'
    to = DateTime.now.strftime('%Y-%m-%d')
    api_str = "/api/v3/historical-price-full/#{ast.symbol}"
    prms = {from: from, to: to}
    dps = run_method(ast.data_source, api_str, prms)
    dps['historical'].each do |dd|
      tm = DateTime.parse(dd['date'])
      ts = tm.to_i

      ast.data_points.find_or_initialize_by({
        datetime: tm,
        timestamp: ts,
        open: dd['open'],
        close: ['close'],
        high: dd['high'],
        low: dd['low'],
        volume: dd['volume']
      })
    end

    ast.save
  end
end