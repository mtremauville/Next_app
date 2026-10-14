require "test_helper"
require "minitest/mock"

class MoviePositionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FakeDetails = Struct.new(:result) do
    def call(*) = result
  end

  setup { sign_in users(:one) }

  def dune
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 438631, media_type: "movie", title: "Dune", year: "2021", poster_path: "/dune.jpg",
      overview: "Sur Arrakis", genres: [ "Science-Fiction" ], runtime_minutes: 155, seasons: []
    )
  end

  def save(params)
    Tmdb::TitleDetails.stub :new, ->(*) { FakeDetails.new(dune) } do
      patch movie_position_path(tmdb_id: 438631), params: params
    end
  end

  test "creates the entry and saves the position" do
    assert_difference -> { users(:one).entries.count }, 1 do
      save(hours: "1", minutes: "5", seconds: "0")
    end

    entry = users(:one).entries.find_by!(tmdb_id: 438631)
    assert entry.watching?
    assert_equal 3_900, entry.position_seconds
    assert_redirected_to movie_path(438631)
  end

  test "updates the position of an existing entry" do
    entry = users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", runtime_minutes: 155)

    assert_no_difference "Entry.count" do
      save(hours: "0", minutes: "30", seconds: "0")
    end

    assert_equal 1_800, entry.reload.position_seconds
    assert entry.watching?
  end

  test "refuses a position beyond the runtime" do
    assert_no_difference "Entry.count" do
      save(hours: "3", minutes: "0", seconds: "0")
    end

    assert_match(/dépasse/, flash[:alert])
  end

  test "refuses a position for a movie already watched" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie", status: :watched)

    save(hours: "0", minutes: "30", seconds: "0")

    assert_match(/déjà vu/, flash[:alert])
  end

  test "an invalid position creates nothing" do
    assert_no_difference "Entry.count" do
      save(hours: "0", minutes: "0", seconds: "0")
    end

    assert flash[:alert].present?
  end

  test "clears the position but keeps the movie in progress" do
    entry = users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie",
                                        status: :watching, position_seconds: 600)

    delete movie_position_removal_path(tmdb_id: 438631)

    assert_nil entry.reload.position_seconds
    assert entry.watching?
    assert_redirected_to movie_path(438631)
  end

  test "redirects to sign in when signed out" do
    sign_out :user
    patch movie_position_path(tmdb_id: 438631), params: { hours: "1" }

    assert_redirected_to new_user_session_path
  end
end
