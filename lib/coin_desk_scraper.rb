module CoinDeskScraper
  def self.scrape(text_source)
    page = Scrape.raw(text_source.url)
    sitemaps = page.css('sitemap')[0..5].map do |row|
    # sitemaps = page.css('sitemap')[0..2].map do |row|
      url = row.css('loc').text
      if url =~ /post-sitemap/
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

  def self.scrape_article(carticle)
    newspaper_response = Nlp.extract_text(carticle.url)
    ss = newspaper_response['sentences']
    ss.each.with_index do |sss, i|
      res = carticle.crypto_sentences.find_or_create_by(
        content: sss,
        position: i
      )
      # puts res.errors.inspect
    end

  end
end