class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :playlist, optional: true
  before_save :set_watched_at, if: :status_changed?
  has_many :episode_progresses, dependent: :destroy
  enum :status, { to_watch: 0, watching: 1, watched: 2 }

  validates :title, presence: true
  validates :status, presence: true
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validate :playlist_belongs_to_same_user
  validates :media_type, inclusion: { in: %w[movie tv] }, allow_blank: true
  validates :poster_path, format: { with: %r{\A/[\w\-.]+\z} }, allow_blank: true

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

  private

  def playlist_belongs_to_same_user
    return if playlist.nil? || playlist.user_id == user_id

    errors.add(:playlist, "must belong to the same user")
  end

  def set_watched_at
    self.watched_at = watched? ? Time.current : nil
  end
end
