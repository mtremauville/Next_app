module ProgressHelper
  def state_label(state) = t("statuses.#{state}")
  def series_state_label(state) = t("series_states.#{state}")
  def resume_item_label(item)
    return item.entry.title unless item.episode

    "#{item.entry.title} · S#{item.episode.season_number}E#{item.episode.episode_number}"
  end

  def resume_item_path(item)
    return entry_target_path(item.entry) unless item.episode

    series_path(item.entry.tmdb_id, season: item.episode.season_number, anchor: "episodes")
  end

  def series_progress_text(row)
    return "#{row.watched}/#{row.total} · #{row.percent} %" if row.total.positive?

    row.entry.watched? ? "100 %" : "-"
  end
end
