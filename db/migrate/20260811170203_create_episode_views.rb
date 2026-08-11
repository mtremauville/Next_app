class CreateEpisodeViews < ActiveRecord::Migration[8.1]
  def change
    create_table :episode_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :episode, null: false, foreign_key: true
      t.datetime :watched_at, null: false

      t.timestamps
    end

    add_index :episode_views, [ :user_id, :episode_id ], unique: true
  end
end
