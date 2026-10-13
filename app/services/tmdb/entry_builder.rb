module Tmdb
  class EntryBuilder
    def initialize(details: TitleDetails.new)
      @details = details
    end

    def call(user, media_type, tmdb_id)
      title = @details.call(media_type, tmdb_id)
      total = Array(title.seasons).sum { |season| season.episode_count.to_i }

      user.entries.build(
        title: title.title,
        media_type: title.media_type,
        tmdb_id: title.tmdb_id,
        year: title.year,
        poster_path: title.poster_path,
        overview: title.overview,
        runtime_minutes: title.runtime_minutes,
        genres: title.genres.join(","),
        episodes_total: (total if media_type == "tv" && total.positive?)
      )
    end
  end
end
