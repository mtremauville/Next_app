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

  test "a position is only kept while the episode is being watched" do
    progress = @entry.episode_progresses.create!(season_number: 1, episode_number: 1,
                                                 status: :watching, position_seconds: 600)
    assert_equal 600, progress.reload.position_seconds

    progress.update!(status: :watched)
    assert_nil progress.reload.position_seconds
  end

  test "a position cannot exceed the known runtime" do
    progress = @entry.episode_progresses.build(season_number: 1, episode_number: 1, status: :watching,
                                               position_seconds: 3_601, runtime_minutes: 60)

    assert_not progress.valid?
    assert_match(/dépasse/, progress.errors.full_messages.to_sentence)
  end

  test "a position is accepted when the runtime is unknown" do
    assert @entry.episode_progresses.build(season_number: 1, episode_number: 1,
                                           status: :watching, position_seconds: 99_999).valid?
  end

  test "a position must be positive" do
    assert_not @entry.episode_progresses.build(season_number: 1, episode_number: 1,
                                               status: :watching, position_seconds: 0).valid?
  end
end
