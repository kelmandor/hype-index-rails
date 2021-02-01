class DataPoint < ApplicationRecord
  belongs_to :asset
  belongs_to :time_object
end
