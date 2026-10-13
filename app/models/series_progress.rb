class SeriesProgress
  def initialize(entry, seasons)
    @seasons = Array(seasons)
    known = @seasons.map(&:number)
    rows = entry&.persisted? ? entry.episode_progresses.pluck(:season_number, :episode_number, :status) : []

    @statuses = rows.select { |season, _, _| known.include?(season) }
                    .to_h { |season, episode, status| [ [ season, episode ], status ] }
  end

  def episode_status(season, episode)
    @statuses.fetch([ season.to_i, episode.to_i ], "to_watch")
  end

  def season_total(number)
    season = @seasons.find { |item| item.number == number }
    season ? season.episode_count.to_i : 0
  end

  def season_watched(number)
    count_in(number) { |status| status == "watched" }
  end

  def season_started(number)
    count_in(number) { |status| status != "to_watch" }
  end

  def season_percent(number)
    percent_of(season_watched(number), season_total(number))
  end

  def season_state(number)
    total = season_total(number)

    if total.positive? && season_watched(number) >= total
      "watched"
    elsif season_started(number).positive?
      "watching"
    else
      "to_watch"
    end
  end

  def total
    @seasons.sum { |season| season.episode_count.to_i }
  end

  def watched_count
    @statuses.values.count("watched")
  end

  def percent
    percent_of(watched_count, total)
  end

  def state
    numbers = @seasons.map(&:number)

    if numbers.any? && numbers.all? { |number| season_state(number) == "watched" }
      "watched"
    elsif @statuses.values.any? { |status| status != "to_watch" }
      "watching"
    else
      "to_watch"
    end
  end

  private

  def count_in(number)
    @statuses.count { |(season, _), status| season == number && yield(status) }
  end

  def percent_of(count, total)
    return 0 unless total.positive?

    [ count * 100 / total, 100 ].min
  end
end
