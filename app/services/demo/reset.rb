module Demo
  class Reset
    PLAYLISTS = [ "Films du dimanche", "Séries du moment" ].freeze

    MOVIES = [
      { tmdb_id: 27205, status: :watched, rating: 5, platform: "Netflix",
        playlist: "Films du dimanche", watched_days_ago: 40 },      # Inception
      { tmdb_id: 155, status: :watched, rating: 4, platform: "Prime Video",
        playlist: "Films du dimanche", watched_days_ago: 12 },      # The Dark Knight
      { tmdb_id: 157336, status: :watching, platform: "Prime Video",
        playlist: "Films du dimanche", position_seconds: 4_320 },   # Interstellar
      { tmdb_id: 496243, status: :to_watch, playlist: "Films du dimanche" }, # Parasite
      { tmdb_id: 438631, status: :to_watch }                        # Dune
    ].freeze

    SERIES = [
      { tmdb_id: 95396, platform: "Apple TV", playlist: "Séries du moment",
        progress: [ { season: 1, watched: 1..6, watching: { 7 => 1_500 } } ] }, # Severance
      { tmdb_id: 94605, platform: "Netflix", rating: 5, playlist: "Séries du moment",
        progress: [ { season: 1, watched: 1..9 } ] },                           # Arcane
      { tmdb_id: 83867, playlist: "Séries du moment", progress: [] },           # Andor
      { tmdb_id: 1396, progress: [] }                                           # Breaking Bad
    ].freeze

    def initialize(user = User.guest, title_details: Tmdb::TitleDetails.new, season_details: Tmdb::SeasonDetails.new)
      @user = user
      @title_details = title_details
      @season_details = season_details
    end

    def call
      warm_cache

      ActiveRecord::Base.transaction do
        wipe
        playlists = PLAYLISTS.index_with { |name| @user.playlists.create!(name: name) }

        MOVIES.each { |item| create_movie(item, playlists) }
        SERIES.each { |item| create_series(item, playlists) }
      end
    end

    private

    # Toutes les requêtes TMDB passent AVANT la suppression : en cas d'erreur,
    # l'exception remonte et les données actuelles restent intactes.
    def warm_cache
      MOVIES.each { |item| @title_details.call("movie", item[:tmdb_id]) }

      SERIES.each do |item|
        @title_details.call("tv", item[:tmdb_id])
        item[:progress].each { |step| @season_details.call(item[:tmdb_id], step[:season]) }
      end
    end

    def wipe
      @user.entries.destroy_all
      @user.playlists.destroy_all
    end

    def create_movie(item, playlists)
      entry = Tmdb::EntryBuilder.new(details: @title_details).call(@user, "movie", item[:tmdb_id])
      entry.assign_attributes(
        status: item.fetch(:status),
        rating: item[:rating],
        platform: item[:platform],
        playlist: playlists[item[:playlist]],
        position_seconds: item[:position_seconds]
      )
      entry.save!
      entry.update_columns(watched_at: item[:watched_days_ago].days.ago) if item[:watched_days_ago] && entry.watched?
    end

    def create_series(item, playlists)
      tracker = SeriesTracker.new(@user, item[:tmdb_id], title_details: @title_details, season_details: @season_details)
      tracker.entry.assign_attributes(
        rating: item[:rating],
        platform: item[:platform],
        playlist: playlists[item[:playlist]]
      )

      item[:progress].each do |step|
        step[:watched].each { |episode| tracker.mark_episode(step[:season], episode, "watched") }
        step.fetch(:watching, {}).each { |episode, seconds| tracker.save_position(step[:season], episode, seconds) }
      end

      tracker.entry.save! if tracker.entry.new_record?
    end
  end
end
