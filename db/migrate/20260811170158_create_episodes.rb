class CreateEpisodes < ActiveRecord::Migration[8.1]
  def change
    create_table :episodes do |t|
      t.references :season, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :episodes, [ :season_id, :number ], unique: true
  end
end
