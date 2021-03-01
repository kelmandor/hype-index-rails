class ArticleMatchAssetsWorker
  include Sidekiq::Worker

  def perform(article_id)
    a = Article.find(article_id)
    a.match_assets
  end
end
