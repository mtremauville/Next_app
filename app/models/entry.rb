class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :playlist, optional: true
  has_many :episode_progresses, dependent: :destroy

  enum :status, { to_watch: 0, watching: 1, watched: 2 }

  before_validation :clear_position_unless_watching
  before_save :set_watched_at, if: :status_changed?

  validates :title, presence: true
  validates :status, presence: true
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :media_type, inclusion: { in: %w[movie tv] }, allow_blank: true
  validates :poster_path, format: { with: %r{\A/[\w\-.]+\z} }, allow_blank: true
  validates :position_seconds, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :playlist_belongs_to_same_user
  validate :position_within_runtime

  def genre_list
    genres.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def tv? = media_type == "tv"

  def episodes_watched
    episode_progresses.select(&:watched?).size
  end

  def refresh_series_status!
    return unless tv?

    watched = episode_progresses.watched.count
    started = episode_progresses.where.not(status: :to_watch).exists?

    new_status =
      if episodes_total.to_i.positive? && watched >= episodes_total
        :watched
      elsif started
        :watching
      else
        :to_watch
      end

    update!(status: new_status)
  end

  def resume_point
    episode_progresses.select(&:position_seconds).max_by(&:updated_at)
  end

  private

  def playlist_belongs_to_same_user
    return if playlist.nil? || playlist.user_id == user_id

    errors.add(:playlist, "must belong to the same user")
  end

  def set_watched_at
    self.watched_at = watched? ? Time.current : nil
  end

  def clear_position_unless_watching
    self.position_seconds = nil unless watching?
  end

  def position_within_runtime
    return if tv? || position_seconds.blank? || runtime_minutes.blank?
    return if position_seconds <= runtime_minutes * 60

    errors.add(:base, "La position dépasse la durée du film (#{runtime_minutes} min).")
  end
end
