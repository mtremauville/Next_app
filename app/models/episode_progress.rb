class EpisodeProgress < ApplicationRecord
  belongs_to :entry

  enum :status, { to_watch: 0, watching: 1, watched: 2 }

  before_validation :clear_position_unless_watching

  validates :season_number, :episode_number, numericality: { only_integer: true, greater_than: 0 }
  validates :episode_number, uniqueness: { scope: [ :entry_id, :season_number ] }
  validates :position_seconds, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :position_within_runtime

  private

  def clear_position_unless_watching
    self.position_seconds = nil unless watching?
  end

  def position_within_runtime
    return if position_seconds.blank? || runtime_minutes.blank?
    return if position_seconds <= runtime_minutes * 60

    errors.add(:base, :position_exceeds_episode, minutes: runtime_minutes)
  end
end
