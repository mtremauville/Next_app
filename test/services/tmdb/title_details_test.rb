require "test_helper"

class Tmdb::TitleDetailsTest < ActiveSupport::TestCase
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

  def movie_payload
    {
      "id" => 438631, "title" => "Dune", "tagline" => "Au-delà de la peur",
      "release_date" => "2021-09-15", "poster_path" => "/dune.jpg", "overview" => "Sur Arrakis",
      "runtime" => 155, "vote_average" => 7.84, "genres" => [ { "name" => "Science-Fiction" } ],
      "credits" => {
        "cast" => Array.new(15) { |i| { "name" => "Acteur #{i}", "character" => "Rôle #{i}", "profile_path" => nil } },
        "crew" => [
          { "name" => "Denis Villeneuve", "job" => "Director" },
          { "name" => "Jon Spaihts", "job" => "Screenplay" },
          { "name" => "Eric Roth", "job" => "Writer" },
          { "name" => "Hans Zimmer", "job" => "Original Music Composer" },
          { "name" => "Greig Fraser", "job" => "Director of Photography" },
          { "name" => "Quelqu'un", "job" => "Gaffer" }
        ]
      }
    }
  end

  test "maps a movie with its cast and technical crew" do
    client = FakeClient.new(movie_payload)
    title = Tmdb::TitleDetails.new(client: client).call("movie", 438631)

    assert_equal "/movie/438631", client.calls.first.first
    assert_equal "credits", client.calls.first.last[:append_to_response]
    assert_equal "Dune", title.title
    assert_equal "2021", title.year
    assert_equal 155, title.runtime_minutes
    assert_equal 7.8, title.rating
    assert_equal [ "Science-Fiction" ], title.genres
    assert_equal 12, title.cast.size
    assert_equal %w[director writer composer cinematography], title.crew.keys
    assert_equal [ "Jon Spaihts", "Eric Roth" ], title.crew["writer"]
  end

  test "a TV show runtime is episode length times episode count" do
    payload = { "id" => 1, "name" => "Severance", "first_air_date" => "2022-02-17",
                "episode_run_time" => [ 50 ], "number_of_episodes" => 9 }
    title = Tmdb::TitleDetails.new(client: FakeClient.new(payload)).call("tv", 1)

    assert_equal "Severance", title.title
    assert_equal 450, title.runtime_minutes
    assert_empty title.cast
    assert_empty title.crew
  end

  test "rejects an unknown media type" do
    assert_raises(ArgumentError) { Tmdb::TitleDetails.new(client: FakeClient.new({})).call("person", 1) }
  end

  test "rejects a non numeric id" do
    assert_raises(ArgumentError) { Tmdb::TitleDetails.new(client: FakeClient.new({})).call("movie", "../x") }
  end
    test "a TV show exposes its creators and numbered seasons without specials" do
      payload = {
        "id" => 95396, "name" => "Severance", "created_by" => [ { "name" => "Dan Erickson" } ],
        "seasons" => [
          { "season_number" => 0, "name" => "Épisodes spéciaux", "episode_count" => 2 },
          { "season_number" => 1, "name" => "Saison 1", "episode_count" => 9, "air_date" => "2022-02-18" },
          { "season_number" => 2, "name" => "", "episode_count" => 10 }
        ]
      }
      title = Tmdb::TitleDetails.new(client: FakeClient.new(payload)).call("tv", 95396)

      assert_equal [ "Dan Erickson" ], title.creators
      assert_equal [ 1, 2 ], title.seasons.map(&:number)
      assert_equal "Saison 2", title.seasons.last.name
      assert_equal "2022", title.seasons.first.year
    end
end
