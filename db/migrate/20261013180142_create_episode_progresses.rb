class CreateEpisodeProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :episode_progresses do |t|
      t.references :entry, null: false, foreign_key: true
      t.integer :season_number, null: false
      t.integer :episode_number, null: false
      t.integer :status, null: false, default: 0
      t.integer :runtime_minutes

      t.timestamps
    end

    add_index :episode_progresses, [ :entry_id, :season_number, :episode_number ],
              unique: true, name: "index_episode_progresses_on_episode"
  end
end
