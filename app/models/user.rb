class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :entries, dependent: :destroy
  has_many :playlists, dependent: :destroy
  GUEST_EMAIL = "guest@next.tremic.fr".freeze
  def guest? = email == GUEST_EMAIL
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  def self.guest
    find_by!(email: GUEST_EMAIL)
  end
end
