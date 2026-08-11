class WatchlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :title

  enum :status, { to_watch: 0, in_progress: 1, watched: 2 }

  validates :title_id, uniqueness: { scope: :user_id }
end
