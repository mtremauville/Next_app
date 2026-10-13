require "test_helper"

class SeriesTrackerTest < ActiveSupport::TestCase
  TitleSource = Struct.new(:result) do
    def call(*) = result
  end

  SeasonSource = Struct.new(:result) do
    def call(*) = result
  end

  def title
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 95396, media_type: "tv", title: "Severance", year: "2022", genres: [ "Drame" ],
      runtime_minutes: 100,
      seasons: [ Tmdb::TitleDetails::Season.new(number: 1, name: "Saison 1", episode_count: 2) ]
    )
  end

  def season
    episodes = [ 1, 2 ].map do |number|
      Tmdb::SeasonDetails::Episode.new(number: number, name: "Épisode #{number}", runtime_minutes: 50, guests: [], crew: {})
    end
    Tmdb::SeasonDetails::Result.new(season_number: 1, name: "Saison 1", episodes: episodes)
  end

  def tracker
    SeriesTracker.new(users(:one), 95396, title_details: TitleSource.new(title), season_details: SeasonSource.new(season))
  end

  def series_entry
    users(:one).entries.find_by!(tmdb_id: 95396)
  end

  test "marking an episode creates the series entry and its progress" do
    assert_difference "Entry.count", 1 do
      tracker.mark_episode(1, 1, "watched")
    end

    assert_equal 2, series_entry.episodes_total
    assert series_entry.watching?

    progress = series_entry.episode_progresses.find_by!(season_number: 1, episode_number: 1)
    assert progress.watched?
    assert_equal 50, progress.runtime_minutes
  end

  test "marking the whole season completes the series" do
    tracker.mark_season(1, "watched")

    assert series_entry.watched?
    assert_not_nil series_entry.watched_at
    assert_equal 2, series_entry.episode_progresses.watched.count
  end

  test "resetting a season puts the series back to watch" do
    tracker.mark_season(1, "watched")
    tracker.mark_season(1, "to_watch")

    assert series_entry.to_watch?
  end

  test "an unknown episode creates nothing" do
    assert_no_difference [ "Entry.count", "EpisodeProgress.count" ] do
      assert_raises(SeriesTracker::UnknownEpisode) { tracker.mark_episode(1, 99, "watched") }
    end
  end

  test "an existing entry without a total gets one" do
    entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv")

    tracker.mark_episode(1, 1, "watched")

    assert_equal 2, entry.reload.episodes_total
  end
end
