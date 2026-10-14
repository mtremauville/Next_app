require "test_helper"

class Stats::DashboardTest < ActiveSupport::TestCase
  def stats
    Stats::Dashboard.new(users(:one))
  end

  def series(attrs = {})
    users(:one).entries.create!({ title: "Severance", tmdb_id: 95396, media_type: "tv", episodes_total: 4 }.merge(attrs))
  end

  test "counts only the user's own entries" do
    assert_equal users(:one).entries.count, stats.total
  end

  test "by_status returns every status" do
    assert_equal Entry.statuses.keys, stats.by_status.keys
  end

  test "by_month returns the requested number of months" do
    assert_equal 6, stats.by_month.size
  end

  test "marking an entry watched sets watched_at" do
    entry = entries(:severance)
    entry.update!(status: :watched)
    assert_not_nil entry.reload.watched_at
  end

  test "watched minutes sum the runtime of watched movies" do
    entries(:inception).update_columns(runtime_minutes: 148)

    assert_equal 148, stats.watched_minutes
  end

  test "watched minutes count watched episodes, even in a series still in progress" do
    show = series
    show.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched, runtime_minutes: 50)
    show.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watching, runtime_minutes: 50)
    entries(:inception).update_columns(runtime_minutes: 148)

    assert_equal 148 + 50, stats.watched_minutes
  end

  test "a watched series without tracked episodes keeps its estimated runtime" do
    users(:one).entries.create!(title: "Old", tmdb_id: 1, media_type: "tv", status: :watched, runtime_minutes: 300)
    entries(:inception).update_columns(runtime_minutes: 0)

    assert_equal 300, stats.watched_minutes
  end

  test "a watched series with tracked episodes is never counted twice" do
    show = series(status: :watched, runtime_minutes: 200)
    show.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched, runtime_minutes: 50)
    entries(:inception).update_columns(runtime_minutes: 0)

    assert_equal 50, stats.watched_minutes
  end

  test "a title typed by hand without a media type is counted as a movie" do
    entries(:inception).update_columns(media_type: nil, runtime_minutes: 120)

    assert_equal 120, stats.watched_minutes
  end

  test "episodes watched counts only watched episodes" do
    show = series
    show.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)
    show.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watching)

    assert_equal 1, stats.episodes_watched
  end

  test "episodes of other users are never counted" do
    other = users(:two).entries.create!(title: "Andor", tmdb_id: 83867, media_type: "tv")
    other.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched, runtime_minutes: 60)

    assert_equal 0, stats.episodes_watched
    assert_equal 0, stats.watched_minutes
  end

  test "series rows give the progress of each series, in progress first" do
    finished = series(title: "Zorro", tmdb_id: 2, episodes_total: 1, status: :watched)
    finished.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)
    running = series(title: "Andor", tmdb_id: 3, episodes_total: 4, status: :watching)
    running.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)
    waiting = series(title: "Alpha", tmdb_id: 4, episodes_total: 8)

    rows = stats.series_rows

    assert_equal [ "Andor", "Alpha", "Zorro" ], rows.map { |row| row.entry.title }
    assert_equal [ 1, 4, 25 ], [ rows.first.watched, rows.first.total, rows.first.percent ]
    assert_equal 0, rows.find { |row| row.entry == waiting }.percent
    assert_equal 100, rows.find { |row| row.entry == finished }.percent
  end

  test "a legacy watched series without a total shows as complete" do
    legacy = users(:one).entries.create!(title: "Old", tmdb_id: 9, media_type: "tv", status: :watched)

    assert_equal 100, stats.series_rows.find { |row| row.entry == legacy }.percent
  end

  test "series counts group the series by state" do
    series(title: "A", tmdb_id: 2, status: :watching)
    series(title: "B", tmdb_id: 3)
    series(title: "C", tmdb_id: 4, status: :watched)

    assert_equal({ "watching" => 1, "to_watch" => 1, "watched" => 1 }, stats.series_counts)
  end

  test "resume items list movies and episodes with a saved position and the time left" do
    users(:one).entries.create!(title: "Dune", media_type: "movie", status: :watching,
                                position_seconds: 3_600, runtime_minutes: 155)
    series.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watching,
                                      position_seconds: 600, runtime_minutes: 50)

    items = stats.resume_items

    assert_equal 2, items.size
    movie = items.find { |item| item.episode.nil? }
    episode = items.find(&:episode)
    assert_equal 155 * 60 - 3_600, movie.remaining_seconds
    assert_equal 50 * 60 - 600, episode.remaining_seconds
    assert_equal 2, episode.episode.episode_number
  end

  test "the time left is unknown when the runtime is unknown" do
    users(:one).entries.create!(title: "Dune", media_type: "movie", status: :watching, position_seconds: 600)

    assert_nil stats.resume_items.first.remaining_seconds
  end

  test "titles without a position are not offered to resume" do
    assert_empty stats.resume_items
  end
end
