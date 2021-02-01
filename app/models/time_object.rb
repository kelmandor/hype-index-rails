class TimeObject < ApplicationRecord
  def self.init_all_times(date_string = '2013-01-01')
    start_time = DateTime.parse(date_string)
    current_time = start_time
    while current_time < DateTime.now
      ts = current_time.to_i
      obj = {
        datetime: current_time,
        timestamp: ts
      }
      self.find_or_create_by(obj)
      current_time += 1.minute
    end
  end
end
