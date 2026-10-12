module EntriesHelper
  STATUS_LABELS = {
    "to_watch" => "À voir",
    "watching" => "En cours",
    "watched" => "Vu"
  }.freeze

  def status_label(status)
    STATUS_LABELS.fetch(status.to_s)
  end

  def status_options
    Entry.statuses.keys.map { |status| [ status_label(status), status ] }
  end

  POSTER_BASE = "https://image.tmdb.org/t/p/w185".freeze

  def poster_tag(entry)
    return if entry.poster_path.blank?

    image_tag "#{POSTER_BASE}#{entry.poster_path}", alt: "Affiche de #{entry.title}",
              class: "nerv-poster", loading: "lazy"
  end

  def format_duration(minutes)
    hours, mins = minutes.to_i.divmod(60)
    hours.zero? ? "#{mins} min" : "#{hours} h #{mins.to_s.rjust(2, '0')}"
  end
end
