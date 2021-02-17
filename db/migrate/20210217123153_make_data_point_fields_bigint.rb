class MakeDataPointFieldsBigint < ActiveRecord::Migration[6.0]
  def change
    change_column :data_points, :market_cap, :integer, limit: 8
    change_column :data_points, :volume, :integer, limit: 8
  end
end
