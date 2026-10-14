require "test_helper"

class EntriesHelperTest < ActionView::TestCase
  test "a movie links to its movie page" do
    entry = Entry.new(tmdb_id: 1, media_type: "movie")
    assert_equal movie_path(1), entry_target_path(entry)
  end

  test "a TV show links to its series page" do
    entry = Entry.new(tmdb_id: 2, media_type: "tv")
    assert_equal series_path(2), entry_target_path(entry)
  end

  test "an entry without a TMDB id has no detail page" do
    entry = entries(:inception)
    assert_equal edit_entry_path(entry), entry_target_path(entry)
  end
    test "format_position formats seconds, minutes and hours" do
    assert_equal "30 s", format_position(30)
    assert_equal "42 min", format_position(2_520)
    assert_equal "42 min 10 s", format_position(2_530)
    assert_equal "1 h 05 min", format_position(3_900)
    assert_equal "1 h 00 min 30 s", format_position(3_630)
  end

  test "resume_text for a movie" do
    movie = Entry.new(media_type: "movie", status: :watching, position_seconds: 2_520)

    assert_equal "Reprendre à 42 min", resume_text(movie)
    assert_nil resume_text(Entry.new(media_type: "movie"))
  end
end
