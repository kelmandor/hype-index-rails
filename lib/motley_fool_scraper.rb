module MotleyFoolScraper
  def self.scrape(text_source, date_start = (DateTime.now.beginning_of_month - 14.months))
    curr = date_start
    while curr < DateTime.now
      # scrape_for_month(text_source, curr)
      MotleyFoolScrapeMonthWorker.perform_async(text_source.id, curr.strftime("%Y-%m-%d"))
      curr += 1.month
    end
  end

  def self.scrape_for_month(ts, date)
    scrape_url = ts.url
    scrape_url = scrape_url.gsub("YYYY", date.strftime("%Y"))
    scrape_url = scrape_url.gsub("MM", date.strftime("%m"))
    page = Scrape.raw(scrape_url)
    urls = page.css('loc').map{|x| x.text}
    urls.each do |article_url|
      article = ts.articles.find_or_initialize_by(url: article_url)
      article.save
    end
  end

  def self.scrape_time(page)

    DateTime.parse(page.css('.publication-date').first.text.strip)
  end

  def self.scrape_headline(page)
    page.css('h1').text
  end
end