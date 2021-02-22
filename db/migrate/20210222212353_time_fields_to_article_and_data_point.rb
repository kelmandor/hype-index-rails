class TimeFieldsToArticleAndDataPoint < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :datetime, :datetime
    add_column :articles, :timestamp, :integer
    add_column :data_points, :datetime, :datetime
    add_column :data_points, :timestamp, :integer
  end
end
