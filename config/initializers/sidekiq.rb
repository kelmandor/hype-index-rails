# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://localhost:6379/0', password: 'rvdOMkEMO4' }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://localhost:6379/0', password: 'rvdOMkEMO4' }
# end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis-master.default.svc.cluster.local:6379/0', password: 'rvdOMkEMO4' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis-slave.default.svc.cluster.local:6379/0', password: 'rvdOMkEMO4' }
end

