class TimeObject < ApplicationRecord
  def self.init_all_times(date_string = '2013-01-01')
    start_time = DateTime.parse(date_string)
    current_time = start_time
    while current_time < DateTime.now
      time_to_object(current_time)
      current_time += 1.minute
    end
  end

  def self.time_to_object(tm)
    ts = tm.to_i
    obj = {
      datetime: tm,
      timestamp: ts
    }
    self.find_or_create_by(obj)
  end
end
