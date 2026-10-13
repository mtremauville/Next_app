require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:one) }

  test "index lists only my playlists" do
    get playlists_path
    assert_response :success
    assert_select "h2", text: "Films du dimanche"
    assert_select "h2", text: "Liste de l'autre", count: 0
  end

  test "create adds a playlist for the current user" do
    assert_difference -> { users(:one).playlists.count }, 1 do
      post playlists_path, params: { playlist: { name: "Séries" } }
    end
    assert_redirected_to playlists_path
  end

  test "create with a blank name re-renders the form" do
    assert_no_difference "Playlist.count" do
      post playlists_path, params: { playlist: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "update renames my playlist" do
    patch playlist_path(playlists(:empty_list)), params: { playlist: { name: "Renommée" } }
    assert_redirected_to playlists_path
    assert_equal "Renommée", playlists(:empty_list).reload.name
  end

  test "destroy removes the playlist but keeps its entries" do
    assert_difference "Playlist.count", -1 do
      delete playlist_path(playlists(:sunday_movies))
    end
    assert_redirected_to playlists_path
    assert_nil entries(:inception).reload.playlist_id
  end

  test "cannot edit another user's playlist" do
    get edit_playlist_path(playlists(:other_user_list))
    assert_redirected_to root_path
  end

  test "redirects to sign in when signed out" do
    sign_out :user
    get playlists_path
    assert_redirected_to new_user_session_path
  end

  test "show lists the titles with links to their pages" do
  playlist = playlists(:sunday_movies)
  users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", playlist: playlist)
  users(:one).entries.create!(title: "Andor", tmdb_id: 83867, media_type: "tv", playlist: playlist)

  get playlist_path(playlist)

  assert_response :success
  assert_select "h1", "Films du dimanche"
  assert_select "a[href=?]", movie_path(438631)
  assert_select "a[href=?]", series_path(83867)
  assert_select "h2", /Films/
  assert_select "h2", /Séries/
end

  test "a title without a TMDB id links to its edit form" do
    get playlist_path(playlists(:sunday_movies))

    assert_select "a[href=?]", edit_entry_path(entries(:inception))
    assert_select "h2", text: /Autres/
  end

  test "an empty playlist shows a message" do
    get playlist_path(playlists(:empty_list))

    assert_response :success
    assert_select "p", text: "Cette playlist est vide."
  end

  test "cannot open another user's playlist" do
    get playlist_path(playlists(:other_user_list))
    assert_redirected_to root_path
  end

  test "show redirects to sign in when signed out" do
    sign_out :user
    get playlist_path(playlists(:sunday_movies))
    assert_redirected_to new_user_session_path
  end
end
