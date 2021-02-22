class MigrateTimeToDatePointWorker
  include Sidekiq::Worker

  def perform(data_point_id)
    dp = DataPoint.find(data_point_id)
    dp.datetime = dp.time_object.datetime
    dp.timestamp = dp.time_object.timestamp
    dp.save
  end
end
