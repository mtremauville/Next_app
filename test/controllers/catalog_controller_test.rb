require "test_helper"
require "minitest/mock"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FakeCatalog = Struct.new(:page) do
    def popular(*, **) = page
    def search(*, **) = page
  end

  def fake_catalog
    item = Tmdb::Catalog::Item.new(tmdb_id: 27205, title: "Inception", media_type: "movie",
                                   year: "2010", poster_path: "/abc.jpg", overview: "")
    FakeCatalog.new(Tmdb::Catalog::Page.new(items: [ item ], page: 1, total_pages: 3))
  end

  test "shows the gallery with links to the detail pages" do
    sign_in users(:one)
    Tmdb::Catalog.stub :new, fake_catalog do
      get catalog_path
    end

    assert_response :success
    assert_select ".nerv-gallery-title", text: "Inception"
    assert_select "a[href=?]", movie_path(27205)
  end

  test "an unknown type falls back to movies" do
    sign_in users(:one)
    Tmdb::Catalog.stub :new, fake_catalog do
      get catalog_path(type: "evil")
    end

    assert_select "a.is-active", text: "[ Films ]"
  end

  test "redirects to sign in when signed out" do
    get catalog_path
    assert_redirected_to new_user_session_path
  end

  test "each card has an add button and the page has one playlist modal" do
    sign_in users(:one)
    Tmdb::Catalog.stub :new, fake_catalog do
      get catalog_path
    end

    assert_select "button.nerv-add-button[data-tmdb-id='27205'][data-media-type='movie'][data-title='Inception']"
    assert_select "dialog[data-add-to-playlist-target='dialog']", count: 1
    assert_select "select#playlist_id option", text: "Films du dimanche"
    assert_select "select#playlist_id option[value='new']"
  end

  test "the modal never lists another user's playlists" do
    sign_in users(:one)
    Tmdb::Catalog.stub :new, fake_catalog do
      get catalog_path
    end

    assert_select "select#playlist_id option", text: "Liste de l'autre", count: 0
  end
end
