module Tmdb
  class SeasonDetails
    GUEST_LIMIT = 8
    CREW_JOBS = {
      "Director" => "director",
      "Writer" => "writer",
      "Screenplay" => "writer"
    }.freeze
    CREW_ORDER = %w[director writer].freeze

    Episode = Struct.new(:number, :name, :air_date, :runtime_minutes, :overview, :still_path,
                         :guests, :crew, keyword_init: true)
    Result = Struct.new(:season_number, :name, :overview, :episodes, keyword_init: true)

    def initialize(client: Client.new)
      @client = client
    end

    def call(tmdb_id, season_number)
      id = Integer(tmdb_id.to_s, 10)
      season = Integer(season_number.to_s, 10)
      raise ArgumentError, "season must be positive" unless season.positive?

      data = @client.get("/tv/#{id}/season/#{season}")

      Result.new(
        season_number: season,
        name: data["name"].presence || I18n.t("series.fallback_season", number: season),
        overview: data["overview"].presence,
        episodes: Array(data["episodes"]).map { |episode| build_episode(episode) }
      )
    end

    private

    def build_episode(episode)
      Episode.new(
        number: episode["episode_number"],
        name: episode["name"].presence || I18n.t("series.fallback_episode", number: episode["episode_number"]),
        air_date: episode["air_date"].presence,
        runtime_minutes: episode["runtime"].presence,
        overview: episode["overview"].presence,
        still_path: episode["still_path"],
        guests: guests_from(episode),
        crew: crew_from(episode)
      )
    end

    def guests_from(episode)
      Array(episode["guest_stars"]).first(GUEST_LIMIT).map do |guest|
        TitleDetails::Person.new(name: guest["name"], role: guest["character"].presence, photo_path: guest["profile_path"])
      end
    end

    def crew_from(episode)
      grouped = {}
      Array(episode["crew"]).each do |member|
        key = CREW_JOBS[member["job"]]
        next unless key

        names = (grouped[key] ||= [])
        names << member["name"] unless names.include?(member["name"])
      end

      CREW_ORDER.filter_map { |key| [ key, grouped[key] ] if grouped.key?(key) }.to_h
    end
  end
end
