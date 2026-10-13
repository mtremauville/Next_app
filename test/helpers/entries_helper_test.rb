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
end
