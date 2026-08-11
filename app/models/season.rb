class Season < ApplicationRecord
  belongs_to :title
  has_many :episodes, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :title_id }
end
