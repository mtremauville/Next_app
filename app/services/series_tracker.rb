class SeriesTracker
  class UnknownEpisode < StandardError; end

  def initialize(user, tmdb_id, title_details: Tmdb::TitleDetails.new, season_details: Tmdb::SeasonDetails.new)
    @user = user
    @tmdb_id = Integer(tmdb_id.to_s, 10)
    @title_details = title_details
    @season_details = season_details
  end

  def entry
    @entry ||= @user.entries.find_by(tmdb_id: @tmdb_id, media_type: "tv") ||
               Tmdb::EntryBuilder.new(details: @title_details).call(@user, "tv", @tmdb_id)
  end

  def mark_episode(season_number, episode_number, status)
    season = @season_details.call(@tmdb_id, season_number)
    episode = season.episodes.find { |item| item.number == episode_number.to_i }
    raise UnknownEpisode unless episode

    save_progress(season.season_number, [ episode ], status)
  end

  def mark_season(season_number, status)
    season = @season_details.call(@tmdb_id, season_number)
    episodes = season.episodes.select(&:number)
    raise UnknownEpisode if episodes.empty?

    save_progress(season.season_number, episodes, status)
  end

  private

  def save_progress(season_number, episodes, status)
    Entry.transaction do
      entry.save! if entry.new_record?
      ensure_episodes_total

      episodes.each do |episode|
        progress = entry.episode_progresses.find_or_initialize_by(season_number: season_number, episode_number: episode.number)
        progress.update!(status: status, runtime_minutes: episode.runtime_minutes)
      end

      entry.refresh_series_status!
    end
  end

  def ensure_episodes_total
    return if entry.episodes_total.present?

    total = Array(@title_details.call("tv", @tmdb_id).seasons).sum { |season| season.episode_count.to_i }
    entry.update!(episodes_total: total) if total.positive?
  end
end
