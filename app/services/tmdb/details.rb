module Tmdb
  class Details
    Result = Struct.new(:runtime_minutes, :genres, keyword_init: true)

    def initialize(client: Client.new)
      @client = client
    end

    def call(tmdb_id, media_type)
      return unless tmdb_id.present? && %w[movie tv].include?(media_type)

      data = @client.get("/#{media_type}/#{tmdb_id}", language: "fr-FR")

      Result.new(
        runtime_minutes: runtime_for(data, media_type),
        genres: data.fetch("genres", []).filter_map { |g| g["name"] }.join(",")
      )
    rescue Tmdb::Error
      nil
    end

    private

    def runtime_for(data, media_type)
      if media_type == "movie"
        data["runtime"].presence
      else
        per_episode = Array(data["episode_run_time"]).first
        episodes = data["number_of_episodes"]
        per_episode && episodes ? per_episode * episodes : nil
      end
    end
  end
end
