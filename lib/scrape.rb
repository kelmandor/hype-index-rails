module Scrape
  def self.raw(url)
    agent = '-A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30"'
    raw = `curl #{agent} #{url}`
    page = Nokogiri::HTML(raw)
  end

  # def self.json(url)
  #   agent = '-A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30"'
  #   raw = `curl #{agent} #{url}`
  #   JSON.parse
  # end
end