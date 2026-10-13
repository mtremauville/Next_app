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
end
