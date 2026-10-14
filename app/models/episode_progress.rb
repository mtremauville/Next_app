class EpisodeProgress < ApplicationRecord
  belongs_to :entry

  enum :status, { to_watch: 0, watching: 1, watched: 2 }

  validates :season_number, :episode_number, numericality: { only_integer: true, greater_than: 0 }
  validates :episode_number, uniqueness: { scope: [ :entry_id, :season_number ] }
end
