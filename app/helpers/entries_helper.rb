module EntriesHelper
  POSTER_BASE = "https://image.tmdb.org/t/p/w185".freeze

  def poster_tag(entry)
    if entry.poster_path.present?
      image_tag "#{POSTER_BASE}#{entry.poster_path}", alt: t("entries.poster_alt", title: entry.title),
                class: "nerv-poster", loading: "lazy"
    else
      tag.div(entry.title.to_s.first.to_s.upcase, class: "nerv-poster-fallback", "aria-hidden": "true")
    end
  end

  def status_label(status)
    t("statuses.#{status}")
  end

  def status_options
    Entry.statuses.keys.map { |status| [ status_label(status), status ] }
  end

  def format_duration(minutes)
    hours, mins = minutes.to_i.divmod(60)
    hours.zero? ? "#{mins} min" : "#{hours} h #{mins.to_s.rjust(2, '0')}"
  end

  def format_position(seconds)
    hours, rest = seconds.to_i.divmod(3600)
    minutes, secs = rest.divmod(60)

    parts = []
    parts << "#{hours} h" if hours.positive?
    parts << "#{hours.positive? ? minutes.to_s.rjust(2, '0') : minutes} min" if hours.positive? || minutes.positive?
    parts << "#{secs} s" if secs.positive?
    parts.join(" ")
  end

  def resume_text(entry)
    if entry.tv?
      point = entry.resume_point
      return unless point

      t("entries.resume.series", season: point.season_number, episode: point.episode_number,
                                  position: format_position(point.position_seconds))
    elsif entry.position_seconds
      t("entries.resume.movie", position: format_position(entry.position_seconds))
    end
  end

  def entry_target_path(entry)
    return edit_entry_path(entry) if entry.tmdb_id.blank?

    case entry.media_type
    when "tv" then series_path(entry.tmdb_id)
    when "movie" then movie_path(entry.tmdb_id)
    else edit_entry_path(entry)
    end
  end
end
