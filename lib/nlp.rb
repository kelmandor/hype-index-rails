module Nlp

  def self.extract_text(url)
    res = HTTParty.get("#{NEWSPAPER_HOST}/?url=#{url}")
    JSON.parse(res)
  end
end