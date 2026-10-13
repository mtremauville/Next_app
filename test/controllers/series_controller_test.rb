require "test_helper"
require "minitest/mock"

class SeriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FakeTitle = Struct.new(:result) do
    def call(*) = result
  end

  class FakeSeasons
    attr_reader :requested

    def initialize(result)
      @result = result
      @requested = []
    end

    def call(_id, number)
      @requested << number
      raise Tmdb::Error, "down" if @result.nil?

      @result
    end
  end

  setup { sign_in users(:one) }

  def series
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 95396, media_type: "tv", title: "Severance", year: "2022", overview: "Un bureau étrange",
      genres: [ "Drame" ], runtime_minutes: 450, rating: 8.4, cast: [], crew: {},
      creators: [ "Dan Erickson" ],
      seasons: [
        Tmdb::TitleDetails::Season.new(number: 1, name: "Saison 1", episode_count: 9, year: "2022"),
        Tmdb::TitleDetails::Season.new(number: 2, name: "Saison 2", episode_count: 10, year: "2025")
      ]
    )
  end

  def season
    episode = Tmdb::SeasonDetails::Episode.new(
      number: 1, name: "Bonne nouvelle", air_date: "2022-02-18", runtime_minutes: 57,
      overview: "Mark commence un nouveau poste", guests: [ Tmdb::TitleDetails::Person.new(name: "Invité", role: "Rôle") ],
      crew: { "Réalisation" => [ "Ben Stiller" ] }
    )
    Tmdb::SeasonDetails::Result.new(season_number: 1, name: "Saison 1", episodes: [ episode ])
  end

  def visit(path, seasons: FakeSeasons.new(season), title: FakeTitle.new(series))
    Tmdb::TitleDetails.stub :new, ->(*) { title } do
      Tmdb::SeasonDetails.stub :new, ->(*) { seasons } do
        get path
      end
    end
    seasons
  end

  test "shows the series, its seasons and the episodes of the first season" do
    seasons = visit series_path(95396)

    assert_response :success
    assert_select "h1", /Severance/
    assert_select "nav[aria-label='Saisons'] a", count: 2
    assert_select "a.is-active", text: "[ S1 ]"
    assert_select ".nerv-episode h3", /Bonne nouvelle/
    assert_select ".nerv-episode-body p", text: "Mark commence un nouveau poste"
    assert_select ".nerv-episode-credits .nerv-crew dd", text: "Ben Stiller"
    assert_equal [ 1 ], seasons.requested
  end

  test "the season parameter selects another season" do
    seasons = visit series_path(95396, season: 2)

    assert_equal [ 2 ], seasons.requested
    assert_select "a.is-active", text: "[ S2 ]"
  end

  test "an unknown season falls back to the first one" do
    seasons = visit series_path(95396, season: 99)

    assert_equal [ 1 ], seasons.requested
  end

  test "offers the playlist picker for a series" do
    visit series_path(95396)

    assert_select "form[action=?]", catalog_entry_playlist_path(media_type: "tv", tmdb_id: 95396)
  end

  test "the page still renders when the episodes cannot be loaded" do
    visit series_path(95396), seasons: FakeSeasons.new(nil)

    assert_response :success
    assert_select ".nerv-flash--alert", /indisponibles/
  end

  test "redirects to the catalog when TMDB is unavailable" do
    Tmdb::TitleDetails.stub :new, ->(*) { raise Tmdb::Error, "down" } do
      get series_path(95396)
    end

    assert_redirected_to catalog_path
  end

  test "redirects to sign in when signed out" do
    sign_out :user
    get series_path(95396)
    assert_redirected_to new_user_session_path
  end
  test "shows the state of the series, of the season and of each episode" do
    entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv", episodes_total: 19)
    entry.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)

    visit series_path(95396)

    assert_select ".nerv-series-state", text: /En cours/
    assert_select ".nerv-season-state", text: /En cours/
    assert_select ".nerv-season-progress", text: /1\/9 épisodes · 11 %/
    assert_select ".nerv-episode-state", text: /Vu/
    assert_select "form[action=?]", series_season_progress_path(tmdb_id: 95396, season: 1)
  end

  test "a series that was never tracked is to watch" do
    visit series_path(95396)

    assert_select ".nerv-series-state", text: /À voir/
    assert_select ".nerv-episode-state", text: /À voir/
  end
end
