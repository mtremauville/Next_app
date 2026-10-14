module Stats
  class Dashboard
    SeriesRow = Struct.new(:entry, :watched, :total, :percent, keyword_init: true)
    ResumeItem = Struct.new(:entry, :episode, :position_seconds, :remaining_seconds, :updated_at, keyword_init: true)

    SERIES_ORDER = { "watching" => 0, "to_watch" => 1, "watched" => 2 }.freeze

    def initialize(user)
      @entries = user.entries
    end

    def total = @entries.count
    def watched_count = @entries.watched.count

    def by_status
      counts = @entries.group(:status).count
      Entry.statuses.keys.index_with { |status| counts[status] || 0 }
    end

    def by_month(months = 6)
      from = (months - 1).months.ago.beginning_of_month
      counts = @entries.watched.where(watched_at: from..)
                       .group_by { |entry| entry.watched_at.strftime("%Y-%m") }
                       .transform_values(&:size)

      (0...months).map do |offset|
        key = (from + offset.months).strftime("%Y-%m")
        [ key, counts[key] || 0 ]
      end
    end

    def by_media_type
      @entries.where.not(media_type: [ nil, "" ]).group(:media_type).count
    end

    def average_rating
      @entries.where.not(rating: nil).average(:rating)&.round(1)
    end

    def watched_minutes
      movies = not_series.watched.sum(:runtime_minutes)
      episodes = episode_scope.watched.sum(:runtime_minutes)
      legacy = series.watched.where.missing(:episode_progresses).sum(:runtime_minutes)

      movies + episodes + legacy
    end

    def episodes_watched
      episode_scope.watched.count
    end

    def by_genre(limit = 6)
      @entries.watched.where.not(genres: [ nil, "" ]).flat_map(&:genre_list)
              .tally.sort_by { |_, count| -count }.first(limit)
    end

    def series_rows
      @series_rows ||= series.includes(:episode_progresses).map do |entry|
        watched = entry.episode_progresses.select(&:watched?).size
        total = entry.episodes_total.to_i

        SeriesRow.new(entry: entry, watched: watched, total: total, percent: percent_for(entry, watched, total))
      end.sort_by { |row| [ SERIES_ORDER.fetch(row.entry.status), row.entry.title.to_s.downcase ] }
    end

    def series_counts
      counts = series_rows.map { |row| row.entry.status }.tally
      SERIES_ORDER.keys.index_with { |status| counts[status] || 0 }
    end

    def resume_items(limit = 6)
      movies = not_series.where.not(position_seconds: nil).map do |entry|
        ResumeItem.new(entry: entry, episode: nil, position_seconds: entry.position_seconds,
                       remaining_seconds: remaining(entry.runtime_minutes, entry.position_seconds),
                       updated_at: entry.updated_at)
      end

      episodes = episode_scope.watching.where.not(position_seconds: nil).includes(:entry).map do |episode|
        ResumeItem.new(entry: episode.entry, episode: episode, position_seconds: episode.position_seconds,
                       remaining_seconds: remaining(episode.runtime_minutes, episode.position_seconds),
                       updated_at: episode.updated_at)
      end

      (movies + episodes).sort_by(&:updated_at).reverse.first(limit)
    end

    private

    def series = @entries.where(media_type: "tv")

    def not_series = @entries.where("entries.media_type IS NULL OR entries.media_type != 'tv'")

    def episode_scope = EpisodeProgress.where(entry_id: @entries.select(:id))

    def percent_for(entry, watched, total)
      return [ watched * 100 / total, 100 ].min if total.positive?

      entry.watched? ? 100 : 0
    end

    def remaining(runtime_minutes, position_seconds)
      return unless runtime_minutes

      [ runtime_minutes * 60 - position_seconds, 0 ].max
    end
  end
end
