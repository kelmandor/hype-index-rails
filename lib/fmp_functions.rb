module FmpFunctions
  def self.fetch_all_assets(ds)
    data = stocks_list(ds)
    save_data(ds, data)
  end

  def self.run_method(ds, api_str)
    uri = URI.parse("#{ds.url}#{api_str}?apikey=04d26577b3608f4b398bf53f3989ce5c")
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
    stocks.map do |row|
      exchng = Exchange.find_or_create_by(name: row['exchange'])
      hsh = {
        name: row['name'],
        symbol: row['symbol'],
        exchange: exchng
      }

      hsh
    end
  end

  def self.save_data(ds, data)
    data.map do |drow|
      coin = ds.assets.find_or_initialize_by(drow)

      coin.save
    end
  end
end