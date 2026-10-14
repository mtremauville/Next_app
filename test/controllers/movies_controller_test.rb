require "test_helper"
require "minitest/mock"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FakeDetails = Struct.new(:result) do
    def call(*) = result
  end

  def dune
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 438631, media_type: "movie", title: "Dune", year: "2021", overview: "Sur Arrakis",
      genres: [ "Science-Fiction" ], runtime_minutes: 155, rating: 7.8,
      cast: [ Tmdb::TitleDetails::Person.new(name: "Timothée Chalamet", role: "Paul Atreides") ],
      crew: { "Réalisation" => [ "Denis Villeneuve" ] }
    )
  end

  test "shows details, crew, cast and the playlist picker" do
    sign_in users(:one)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      get movie_path(438631)
    end

    assert_response :success
    assert_select "h1", /Dune/
    assert_select ".nerv-crew dd", text: "Denis Villeneuve"
    assert_select ".nerv-cast-name", text: "Timothée Chalamet"
    assert_select "form[action=?]", catalog_entry_playlist_path(media_type: "movie", tmdb_id: 438631)
  end

  test "offers to remove the movie when it is already in a playlist" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", playlist: playlists(:sunday_movies))
    sign_in users(:one)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      get movie_path(438631)
    end

    assert_select "form[action=?]", catalog_entry_playlist_removal_path(media_type: "movie", tmdb_id: 438631)
  end

  test "redirects to the catalog when TMDB is unavailable" do
    sign_in users(:one)
    Tmdb::TitleDetails.stub :new, ->(*) { raise Tmdb::Error, "down" } do
      get movie_path(438631)
    end

    assert_redirected_to catalog_path
  end

  test "redirects to sign in when signed out" do
    get movie_path(438631)
    assert_redirected_to new_user_session_path
  end
    test "shows the resume position form and the saved position" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie",
                                status: :watching, position_seconds: 2_520, runtime_minutes: 155)
    sign_in users(:one)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      get movie_path(438631)
    end

    assert_select "form[action=?]", movie_position_path(tmdb_id: 438631)
    assert_select ".nerv-resume", text: /Reprendre à 42 min/
    assert_select "form[action=?]", movie_position_removal_path(tmdb_id: 438631)
  end

  test "a watched movie has no position form" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", status: :watched)
    sign_in users(:one)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      get movie_path(438631)
    end

    assert_select "form[action=?]", movie_position_path(tmdb_id: 438631), count: 0
  end
end
