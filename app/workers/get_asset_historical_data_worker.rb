class GetAssetHistoricalDataWorker
  include Sidekiq::Worker

  def perform(asset_id)
    ass = Asset.find(asset_id)
    ass.fetch_historical_data
  end
end
