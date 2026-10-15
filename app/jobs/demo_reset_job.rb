class DemoResetJob < ApplicationJob
  queue_as :default

  IDLE_FOR = 30.minutes

  def perform
    guest = User.find_by(email: User::GUEST_EMAIL)
    return unless guest
    return if recently_active?(guest)

    Demo::Reset.new(guest).call
  rescue Tmdb::Error => error
    Rails.logger.warn("Demo reset skipped, TMDB unavailable: #{error.message}")
  end

  private

  def recently_active?(guest)
    latest = [
      guest.entries.maximum(:updated_at),
      guest.playlists.maximum(:updated_at),
      EpisodeProgress.where(entry: guest.entries).maximum(:updated_at)
    ].compact.max

    latest.present? && latest > IDLE_FOR.ago
  end
end
