class WatchlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :title

  enum :status, { to_watch: 0, in_progress: 1, watched: 2 }

  validates :title_id, uniqueness: { scope: :user_id }

  def refresh_status_from_progress!
    return unless title.tv_series?

    total = title.episodes.count
    watched = user.episode_views.where(episode: title.episodes).count

    new_status = if watched.zero?
      :to_watch
    elsif watched == total
      :watched
    else
      :in_progress
    end

    update!(status: new_status)
  end
end
