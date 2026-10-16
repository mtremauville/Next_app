require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "index lists only my entries" do
    get entries_path
    assert_response :success
    assert_select "h2", text: "Inception"
    assert_select "h2", text: "Titre privé", count: 0
  end

  test "create adds an entry for the current user" do
    assert_difference -> { users(:one).entries.count }, 1 do
      post entries_path, params: { entry: { title: "Dune", status: "to_watch" } }
    end
    assert_redirected_to entries_path
  end

  test "create with a blank title re-renders the form" do
    assert_no_difference "Entry.count" do
      post entries_path, params: { entry: { title: "", status: "to_watch" } }
    end
    assert_response :unprocessable_entity
  end

  test "update changes my entry" do
    patch entry_path(entries(:severance)), params: { entry: { status: "watched" } }
    assert_redirected_to entries_path
    assert entries(:severance).reload.watched?
  end

  test "destroy removes my entry" do
    assert_difference "Entry.count", -1 do
      delete entry_path(entries(:severance))
    end
    assert_redirected_to entries_path
  end

  test "cannot edit another user's entry" do
    get edit_entry_path(entries(:other_entry))
    assert_redirected_to root_path
  end

  test "redirects to sign in when signed out" do
    sign_out :user
    get entries_path
    assert_redirected_to new_user_session_path
  end

  test "cannot assign an entry to another user's playlist" do
    patch entry_path(entries(:severance)),
          params: { entry: { playlist_id: playlists(:other_user_list).id } }
    assert_response :unprocessable_entity
    assert_nil entries(:severance).reload.playlist_id
  end

  test "new preselects one of my playlists" do
    get new_entry_path(playlist_id: playlists(:sunday_movies).id)
    assert_response :success
    assert_select "select[name='entry[playlist_id]'] option[selected][value='#{playlists(:sunday_movies).id}']"
  end

  test "new ignores another user's playlist" do
    get new_entry_path(playlist_id: playlists(:other_user_list).id)
    assert_response :success
    assert_select "select[name='entry[playlist_id]'] option[selected][value]:not([value=''])", count: 0
  end

  test "create in a playlist redirects to playlists" do
    post entries_path, params: { entry: { title: "Dune", status: "to_watch",
                                          playlist_id: playlists(:sunday_movies).id } }
    assert_redirected_to playlists_path
  end

  test "watch marks my entry as watched" do
    patch watch_entry_path(entries(:severance))
    assert entries(:severance).reload.watched?
  end

  test "cannot mark another user's entry as watched" do
    patch watch_entry_path(entries(:other_entry))
    assert_redirected_to root_path
    assert_not entries(:other_entry).reload.watched?
  end

  test "index renders the filters" do
    get entries_path
    assert_select "[data-controller='filter']"
    assert_select "article[data-status]"
  end

  test "each card has a header, a content area and a footer" do
    get entries_path
    assert_select "article.nerv-card > header.nerv-card-header"
    assert_select "article.nerv-card > .nerv-card-content"
    assert_select "article.nerv-card > footer.nerv-card-footer"
  end
  test "titles link to their movie or series page" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie")
    users(:one).entries.create!(title: "Andor", tmdb_id: 83867, media_type: "tv")

    get entries_path

    assert_select "article.nerv-card header a[href=?]", movie_path(438631)
    assert_select "article.nerv-card header a[href=?]", series_path(83867)
  end

  test "a title without a TMDB id links to its edit form" do
    get entries_path
    assert_select "article.nerv-card header a[href=?]", edit_entry_path(entries(:inception))
  end
  test "home titles link to their detail page" do
    users(:one).entries.create!(title: "Andor", tmdb_id: 83867, media_type: "tv", status: :watching)
    sign_in users(:one)
    get root_url

    assert_select ".nerv-mini-text a[href=?]", series_path(83867)
  end
  test "cards show where to resume a movie" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie",
                                status: :watching, position_seconds: 2_520)

    get entries_path

    assert_select ".nerv-card-resume", text: "Reprendre à 42 min"
  end
end
