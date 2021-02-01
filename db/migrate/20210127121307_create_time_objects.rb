class CreateTimeObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :time_objects do |t|
      t.datetime :datetime
      t.integer :timestamp
      t.timestamps
    end
  end
end
