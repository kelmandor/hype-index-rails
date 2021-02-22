class MigrateTimeToArticleWorker
  include Sidekiq::Worker

  def perform(article_id)
    a = Article.find(article_id)
    a.datetime = a.time_object.datetime
    a.timestamp = a.time_object.timestamp
    a.save!
  end
end
