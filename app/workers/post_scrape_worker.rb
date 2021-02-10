class PostScrapeWorker
  include Sidekiq::Worker

  def perform(article_id)
    a = Article.find(article_id)
    a.scrape_and_save
  end
end
