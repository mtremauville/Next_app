class Episode < ApplicationRecord
  belongs_to :season
  has_many :episode_views, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :season_id }
  validates :name, presence: true
end
