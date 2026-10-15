module Tmdb
  class TitleDetails
    CAST_LIMIT = 12
    CREW_JOBS = {
      "Director" => "director",
      "Screenplay" => "writer",
      "Writer" => "writer",
      "Original Music Composer" => "composer",
      "Director of Photography" => "cinematography"
    }.freeze
    CREW_ORDER = %w[director writer composer cinematography].freeze

    Person = Struct.new(:name, :role, :photo_path, keyword_init: true)
    Season = Struct.new(:number, :name, :episode_count, :year, keyword_init: true)
    Result = Struct.new(:tmdb_id, :media_type, :title, :tagline, :year, :poster_path, :overview,
                        :genres, :runtime_minutes, :rating, :cast, :crew, :creators, :seasons,
                        keyword_init: true)

    def initialize(client: Client.new)
      @client = client
    end

    def call(media_type, tmdb_id)
      raise ArgumentError, "unknown media type" unless %w[movie tv].include?(media_type)

      id = Integer(tmdb_id.to_s, 10)
      data = @client.get("/#{media_type}/#{id}", append_to_response: "credits")
      build(data, media_type)
    end

    private

    def build(data, media_type)
      credits = data["credits"] || {}
      date = data["release_date"].presence || data["first_air_date"].presence
      rating = data["vote_average"].to_f

      Result.new(
        tmdb_id: data["id"],
        media_type: media_type,
        title: data["title"].presence || data["name"],
        tagline: data["tagline"].presence,
        year: date&.slice(0, 4),
        poster_path: data["poster_path"],
        overview: data["overview"].presence,
        genres: data.fetch("genres", []).filter_map { |genre| genre["name"] },
        runtime_minutes: runtime_for(data, media_type),
        rating: rating.positive? ? rating.round(1) : nil,
        cast: cast_from(credits),
        crew: crew_from(credits),
        creators: Array(data["created_by"]).filter_map { |creator| creator["name"] },
        seasons: seasons_from(data)
      )
    end

    def runtime_for(data, media_type)
      if media_type == "movie"
        data["runtime"].presence
      else
        per_episode = Array(data["episode_run_time"]).first
        episodes = data["number_of_episodes"]
        per_episode && episodes ? per_episode * episodes : nil
      end
    end

    def cast_from(credits)
      Array(credits["cast"]).first(CAST_LIMIT).map do |member|
        Person.new(name: member["name"], role: member["character"].presence, photo_path: member["profile_path"])
      end
    end

    def crew_from(credits)
      grouped = {}
      Array(credits["crew"]).each do |member|
        key = CREW_JOBS[member["job"]]
        next unless key

        names = (grouped[key] ||= [])
        names << member["name"] unless names.include?(member["name"])
      end

      CREW_ORDER.filter_map { |key| [ key, grouped[key] ] if grouped.key?(key) }.to_h
    end

    def seasons_from(data)
      Array(data["seasons"]).filter_map do |season|
        number = season["season_number"].to_i
        next unless number.positive?

        Season.new(
          number: number,
          name: season["name"].presence || I18n.t("series.fallback_season", number: number),
          episode_count: season["episode_count"],
          year: season["air_date"]&.slice(0, 4)
        )
      end
    end
  end
end
