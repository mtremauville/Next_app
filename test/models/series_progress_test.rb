require "test_helper"

class SeriesProgressTest < ActiveSupport::TestCase
  Season = Struct.new(:number, :episode_count)

  setup do
    @entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv", episodes_total: 5)
    @seasons = [ Season.new(1, 3), Season.new(2, 2) ]
  end

  def mark(season, episode, status)
    @entry.episode_progresses.create!(season_number: season, episode_number: episode, status: status)
  end

  def progress
    SeriesProgress.new(@entry, @seasons)
  end

  test "nothing watched means everything to watch" do
    assert_equal "to_watch", progress.state
    assert_equal "to_watch", progress.season_state(1)
    assert_equal 0, progress.percent
  end

  test "one watched episode puts the season and the series in progress" do
    mark(1, 1, :watched)

    assert_equal "watching", progress.season_state(1)
    assert_equal "to_watch", progress.season_state(2)
    assert_equal "watching", progress.state
    assert_equal 33, progress.season_percent(1)
    assert_equal 20, progress.percent
  end

  test "an episode being watched counts as started but not as watched" do
    mark(1, 1, :watching)

    assert_equal "watching", progress.season_state(1)
    assert_equal 0, progress.season_percent(1)
  end

  test "a fully watched season is watched while the series is still in progress" do
    3.times { |index| mark(1, index + 1, :watched) }

    assert_equal "watched", progress.season_state(1)
    assert_equal "watching", progress.state
    assert_equal 60, progress.percent
  end

  test "every season watched means the series is finished" do
    3.times { |index| mark(1, index + 1, :watched) }
    2.times { |index| mark(2, index + 1, :watched) }

    assert_equal "watched", progress.state
    assert_equal 100, progress.percent
  end

  test "episodes of an unknown season are ignored" do
    mark(9, 1, :watched)

    assert_equal 0, progress.watched_count
    assert_equal "to_watch", progress.state
  end

  test "a series that is not in the list has no progress" do
    empty = SeriesProgress.new(nil, @seasons)

    assert_equal "to_watch", empty.state
    assert_equal "to_watch", empty.episode_status(1, 1)
  end
end
