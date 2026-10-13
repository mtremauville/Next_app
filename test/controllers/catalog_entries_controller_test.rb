require "test_helper"
require "minitest/mock"

class CatalogEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FakeDetails = Struct.new(:result) do
    def call(*) = result
  end

  setup { sign_in users(:one) }

  def dune
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 438631, media_type: "movie", title: "Dune", year: "2021", poster_path: "/dune.jpg",
      overview: "Sur Arrakis", genres: [ "Science-Fiction" ], runtime_minutes: 155
    )
  end

  def add_to(playlist)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      post catalog_entry_playlist_path(media_type: "movie", tmdb_id: 438631), params: { playlist_id: playlist.id }
    end
  end

  test "creates the entry from TMDB and puts it in the playlist" do
    assert_difference -> { users(:one).entries.count }, 1 do
      add_to playlists(:sunday_movies)
    end

    entry = users(:one).entries.find_by!(tmdb_id: 438631)
    assert_equal playlists(:sunday_movies), entry.playlist
    assert_equal "to_watch", entry.status
    assert_equal 155, entry.runtime_minutes
    assert_equal "Science-Fiction", entry.genres
    assert_redirected_to movie_path(438631)
  end

  test "reuses the existing entry" do
    entry = users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie")

    assert_no_difference "Entry.count" do
      add_to playlists(:sunday_movies)
    end
    assert_equal playlists(:sunday_movies), entry.reload.playlist
  end

  test "cannot use another user's playlist" do
    add_to playlists(:other_user_list)

    assert_redirected_to root_path
    assert_nil users(:one).entries.find_by(tmdb_id: 438631)
  end

  test "asks to choose a playlist when none is given" do
    post catalog_entry_playlist_path(media_type: "movie", tmdb_id: 438631)
    assert_redirected_to movie_path(438631)
  end

  test "removes the title from its playlist but keeps it in the list" do
    entry = users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie",
                                        playlist: playlists(:sunday_movies))

    delete catalog_entry_playlist_removal_path(media_type: "movie", tmdb_id: 438631)

    assert_nil entry.reload.playlist_id
    assert Entry.exists?(entry.id)
    assert_redirected_to movie_path(438631)
  end

  test "an unknown media type is not routable" do
    post "/catalog/person/1/playlist"
    assert_response :not_found
  end

  test "adding a series goes back to the series page" do
    show = Tmdb::TitleDetails::Result.new(tmdb_id: 95396, media_type: "tv", title: "Severance", year: "2022",
                                          genres: [], runtime_minutes: 450)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(show) } do
      post catalog_entry_playlist_path(media_type: "tv", tmdb_id: 95396), params: { playlist_id: playlists(:sunday_movies).id }
    end

    assert_redirected_to series_path(95396)
    assert_equal "tv", users(:one).entries.find_by!(tmdb_id: 95396).media_type
  end
end
