class CreateTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :titles do |t|
      t.string :name, null: false
      t.integer :kind, null: false
      t.integer :tmdb_id, null: false
      t.string :poster_path
      t.text :overview
      t.date :release_date

      t.timestamps
    end
    add_index :titles, :tmdb_id, unique: true
  end
end
