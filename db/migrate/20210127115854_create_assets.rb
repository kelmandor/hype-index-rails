class CreateAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :assets do |t|
      t.references :data_source
      t.string :name
      t.string :symbol
      t.string :url
      t.string :data_url
      t.timestamps
    end
  end
end
