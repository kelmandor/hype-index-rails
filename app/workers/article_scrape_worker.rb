class ArticleScrapeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :important

  def perform(article_id)
    a = Article.find(article_id)
    a.scrape
  end
end
