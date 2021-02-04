module CoinDeskScraper
  def self.scrape(text_source)
    page = Scrape.raw(text_source.url)
    sitemaps = page.css('sitemap').map do |row|
    # sitemaps = page.css('sitemap')[0..2].map do |row|
      url = row.css('loc').text
      dt = DateTime.parse(row.css('lastmod').text)
      date_min = DateTime.parse('2020-02-01')
      if (url =~ /post-sitemap/) && (dt > date_min)
      # if url =~ /post-sitemap/
        doc = Scrape.raw(url)
        links = doc.css('loc').map do |link|
          link.text
        end
        links
      end
    end

    sitemaps.flatten.reject{|x| x =~ /\.(jpg|png|jpeg|gif)/ }.each do |article_url|
      article = text_source.articles.find_or_initialize_by(url: article_url)
      article.save
    end
  end

  def self.scrape_time(page)

    DateTime.parse(page.css('time').first.text)
  end

  def self.scrape_headline(page)
    page.css('h1').text
  end
end