require "test_helper"

class EpisodeProgressTest < ActiveSupport::TestCase
  setup do
    @entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv")
  end

  test "defaults to the to_watch status" do
    progress = @entry.episode_progresses.create!(season_number: 1, episode_number: 1)
    assert progress.to_watch?
  end

  test "an episode is recorded once per series" do
    @entry.episode_progresses.create!(season_number: 1, episode_number: 1)
    duplicate = @entry.episode_progresses.build(season_number: 1, episode_number: 1)

    assert_not duplicate.valid?
  end

  test "rejects a season or an episode below 1" do
    assert_not @entry.episode_progresses.build(season_number: 0, episode_number: 1).valid?
    assert_not @entry.episode_progresses.build(season_number: 1, episode_number: 0).valid?
  end
end
