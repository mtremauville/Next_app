require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "is valid with a title, a status and a user" do
    assert Entry.new(title: "Dune", user: users(:one)).valid?
  end

  test "defaults to the to_watch status" do
    assert_equal "to_watch", Entry.new.status
  end

  test "requires a title" do
    entry = Entry.new(user: users(:one))
    assert_not entry.valid?
    assert_includes entry.errors[:title], I18n.t("errors.messages.blank")
  end

  test "rejects a rating outside 1..5" do
    entry = Entry.new(title: "Dune", user: users(:one), rating: 6)
    assert_not entry.valid?
  end

  test "allows a blank rating" do
    assert Entry.new(title: "Dune", user: users(:one), rating: nil).valid?
  end

  test "can belong to a playlist of the same user" do
    entry = Entry.new(title: "Dune", user: users(:one), playlist: playlists(:sunday_movies))
    assert entry.valid?
  end

  test "rejects a playlist owned by another user" do
    entry = Entry.new(title: "Dune", user: users(:one), playlist: playlists(:other_user_list))
    assert_not entry.valid?
  end
  test "accepts a valid TMDB poster path" do
    assert Entry.new(title: "Dune", user: users(:one), poster_path: "/abc.jpg").valid?
  end

  test "rejects a poster path pointing elsewhere" do
    entry = Entry.new(title: "Dune", user: users(:one), poster_path: "https://evil.example/x.jpg")
    assert_not entry.valid?
  end
  test "a series follows the progress of its episodes" do
    entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv", episodes_total: 2)
    entry.refresh_series_status!
    assert entry.to_watch?

    first = entry.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watching)
    entry.refresh_series_status!
    assert entry.watching?

    first.update!(status: :watched)
    entry.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watched)
    entry.refresh_series_status!
    assert entry.watched?
    assert_not_nil entry.watched_at

    first.update!(status: :to_watch)
    entry.refresh_series_status!
    assert entry.watching?
    assert_nil entry.watched_at
  end

  test "a movie is not affected by refresh_series_status!" do
    entries(:inception).refresh_series_status!
    assert entries(:inception).watched?
  end
  test "a movie keeps a resume position while it is being watched" do
    entry = users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", runtime_minutes: 155,
                                        status: :watching, position_seconds: 3_600)
    assert_equal 3_600, entry.reload.position_seconds

    entry.update!(status: :watched)
    assert_nil entry.reload.position_seconds
  end

  test "a position cannot exceed the runtime of a movie" do
    entry = users(:one).entries.build(title: "Dune", media_type: "movie", runtime_minutes: 100,
                                      status: :watching, position_seconds: 6_001)

    assert_not entry.valid?
    assert_match(/dépasse/, entry.errors.full_messages.to_sentence)
  end

  test "a position needs the watching status" do
    entry = users(:one).entries.create!(title: "Dune", status: :to_watch, position_seconds: 100)
    assert_nil entry.position_seconds
  end

  test "the resume point of a series is its latest episode with a position" do
    entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv")
    entry.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watching,
                                    position_seconds: 100, updated_at: 2.days.ago)
    latest = entry.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watching,
                                              position_seconds: 200)

    assert_equal latest, entry.reload.resume_point
  end
end
