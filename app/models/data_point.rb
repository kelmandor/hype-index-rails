class DataPoint < ApplicationRecord
  belongs_to :asset
  belongs_to :time_object

  def by_date
    datetime.to_date.to_s(:db)
  end

  def by_week
    datetime.beginning_of_week.to_date.to_s(:db)
  end
end
