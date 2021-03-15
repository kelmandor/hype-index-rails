class BatchDataPointFetchWorker
  include Sidekiq::Worker

  def perform(q)
    FmpFunctions.fetch_batch_historical(q)
  end
end
