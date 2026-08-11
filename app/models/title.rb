class Title < ApplicationRecord
  has_many :watchlist_entries, dependent: :destroy

  enum :kind, { movie: 0, tv_series: 1 }

  validates :name, presence: true
  validates :kind, presence: true
  validates :tmdb_id, presence: true, uniqueness: true
end
