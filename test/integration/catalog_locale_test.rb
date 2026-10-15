require "test_helper"
require "minitest/mock"

class CatalogLocaleTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class CatalogSource
    def initialize(page)
      @page = page
    end

    def popular(*, **) = @page
    def search(*, **) = @page
  end

  class DetailsSource
    def initialize(result)
      @result = result
    end

    def call(*, **) = @result
  end

  setup { sign_in users(:one) }

  def english!
    patch change_locale_path, params: { locale: "en" }
  end

  def catalog_page
    item = Tmdb::Catalog::Item.new(tmdb_id: 27205, title: "Inception", media_type: "movie",
                                   year: "2010", poster_path: "/abc.jpg", overview: "")
    Tmdb::Catalog::Page.new(items: [ item ], page: 2, total_pages: 3)
  end

  def movie
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 438631, media_type: "movie", title: "Dune", year: "2021", overview: nil,
      genres: [ "Science Fiction" ], runtime_minutes: 155, rating: 7.8,
      cast: [ Tmdb::TitleDetails::Person.new(name: "Timothée Chalamet", role: "Paul") ],
      crew: { "director" => [ "Denis Villeneuve" ], "writer" => [ "Jon Spaihts" ] }
    )
  end

  def show
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 95396, media_type: "tv", title: "Severance", year: "2022", overview: "An office",
      genres: [ "Drama" ], runtime_minutes: 450, rating: 8.4, cast: [], crew: {},
      creators: [ "Dan Erickson" ],
      seasons: [
        Tmdb::TitleDetails::Season.new(number: 1, name: "Season 1", episode_count: 9),
        Tmdb::TitleDetails::Season.new(number: 2, name: "Season 2", episode_count: 10)
      ]
    )
  end

  def season
    episode = Tmdb::SeasonDetails::Episode.new(
      number: 1, name: "Good News", air_date: "2022-02-18", runtime_minutes: 57, overview: nil,
      guests: [ Tmdb::TitleDetails::Person.new(name: "Guest", role: "Role") ],
      crew: { "director" => [ "Ben Stiller" ] }
    )
    Tmdb::SeasonDetails::Result.new(season_number: 1, name: "Season 1", episodes: [ episode ])
  end

  def visit_catalog
    Tmdb::Catalog.stub :new, ->(*) { CatalogSource.new(catalog_page) } do
      get catalog_path
    end
  end

  def visit_movie
    Tmdb::TitleDetails.stub :new, ->(*) { DetailsSource.new(movie) } do
      get movie_path(438631)
    end
  end

  def visit_series(title: show)
    Tmdb::TitleDetails.stub :new, ->(*) { DetailsSource.new(title) } do
      Tmdb::SeasonDetails.stub :new, ->(*) { DetailsSource.new(season) } do
        get series_path(95396)
      end
    end
  end

  test "the catalog is in French by default" do
    visit_catalog

    assert_select "h1", "Catalogue"
    assert_select "a", text: "[ Films ]"
    assert_select "a", text: "[ Suivant ]"
    assert_select "span", text: "Page 2 / 3"
    assert_select "dialog h2", "Ajouter à une playlist"
  end

  test "the catalog is in English" do
    english!
    visit_catalog

    assert_select "h1", "Catalog"
    assert_select "a", text: "[ Movies ]"
    assert_select "a", text: "[ Previous ]"
    assert_select "a", text: "[ Next ]"
    assert_select "input[placeholder='Search for a movie or a series']"
    assert_select "dialog h2", "Add to a playlist"
    assert_select "select#playlist_id option", text: "+ New playlist…"
    assert_select ".nerv-add-button[aria-label*='Inception']"
  end

  test "the movie page is in English with translated crew labels" do
    english!
    visit_movie

    assert_select "h2", "Synopsis"
    assert_select "p", text: "Synopsis not available."
    assert_select ".nerv-crew dt", text: "Director"
    assert_select ".nerv-crew dt", text: "Writing"
    assert_select "h2", "Cast"
    assert_select "li", text: "TMDB 7.8/10"
    assert_select "label", text: "Add to a playlist"
    assert_select "legend", text: /Resume position/
    assert_select "a", text: "[ ← Catalog ]"
  end

  test "the movie page keeps the French crew labels" do
    visit_movie

    assert_select ".nerv-crew dt", text: "Réalisation"
    assert_select ".nerv-crew dt", text: "Scénario"
    assert_select "h2", "Équipe technique"
    assert_select "legend", text: /Position de reprise/
  end

  test "the series page is in English" do
    english!
    visit_series

    assert_select "li", text: "2 seasons"
    assert_select ".nerv-hint", text: "Created by Dan Erickson"
    assert_select ".nerv-season-state", text: /Season 1: To watch/
    assert_select ".nerv-season-head", text: /Mark all as watched/
    assert_select ".nerv-season-head", text: /Reset all to watch/
    assert_select ".nerv-episode-state", text: /To watch/
    assert_select ".nerv-episode-actions", text: /In progress/
    assert_select ".nerv-episode .nerv-hint", text: /February 18, 2022/
    assert_select ".nerv-episode-credits summary", text: "Guests and crew"
    assert_select ".nerv-episode-credits .nerv-crew dt", text: "Director"
  end

  test "the series page shows French dates and plurals" do
    visit_series

    assert_select "li", text: "2 saisons"
    assert_select ".nerv-episode .nerv-hint", text: /18\/02\/2022/
    assert_select ".nerv-season-state", text: /Saison 1 : À voir/
  end

  test "one season is singular" do
    english!
    single = show
    single.seasons = [ single.seasons.first ]
    visit_series(title: single)

    assert_select "li", text: "1 season"
  end

  test "the progress texts follow the language" do
    entry = users(:one).entries.create!(title: "Severance", tmdb_id: 95396, media_type: "tv", episodes_total: 19)
    entry.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)

    english!
    visit_series

    assert_select ".nerv-season-progress", text: /1\/9 episodes · 11%/
    assert_select ".nerv-series-state", text: /In progress/
  end

  test "the playlist picker is in English once the title is in a playlist" do
    users(:one).entries.create!(title: "Dune", tmdb_id: 438631, media_type: "movie",
                                playlist: playlists(:sunday_movies))
    english!
    visit_movie

    assert_select ".nerv-picker", text: /In the playlist/
    assert_select ".nerv-picker", text: /Remove from the playlist/
    assert_select ".nerv-picker", text: /Move to/
  end
end
