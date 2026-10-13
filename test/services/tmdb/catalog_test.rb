require "test_helper"

class Tmdb::CatalogTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :calls

    def initialize(payload)
      @payload = payload
      @calls = []
    end

    def get(path, params = {})
      @calls << [ path, params ]
      @payload
    end
  end

  test "popular movies are mapped with title, year and poster" do
    client = FakeClient.new({ "page" => 1, "total_pages" => 3, "results" => [
      { "id" => 27205, "title" => "Inception", "release_date" => "2010-07-15", "poster_path" => "/abc.jpg" }
    ] })

    page = Tmdb::Catalog.new(client: client).popular("movie")

    assert_equal "/movie/popular", client.calls.first.first
    assert_equal "Inception", page.items.first.title
    assert_equal "2010", page.items.first.year
    assert_equal "movie", page.items.first.media_type
    assert_equal 3, page.total_pages
  end

  test "tv shows use the name and first air date" do
    client = FakeClient.new({ "results" => [ { "id" => 95396, "name" => "Severance", "first_air_date" => "2022-02-17" } ] })
    item = Tmdb::Catalog.new(client: client).popular("tv").items.first

    assert_equal "Severance", item.title
    assert_equal "2022", item.year
    assert_equal "tv", item.media_type
  end

  test "search sends the query to the right endpoint" do
    client = FakeClient.new({ "results" => [] })
    Tmdb::Catalog.new(client: client).search("dune", "movie", page: 2)

    path, params = client.calls.first
    assert_equal "/search/movie", path
    assert_equal "dune", params[:query]
    assert_equal 2, params[:page]
  end

  test "total pages is capped at 500" do
    client = FakeClient.new({ "total_pages" => 12000, "results" => [] })
    assert_equal 500, Tmdb::Catalog.new(client: client).popular("movie").total_pages
  end

  test "rejects an unknown media type" do
    assert_raises(ArgumentError) { Tmdb::Catalog.new(client: FakeClient.new({})).popular("person") }
  end
end
