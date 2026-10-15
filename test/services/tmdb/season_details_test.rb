require "test_helper"

class Tmdb::SeasonDetailsTest < ActiveSupport::TestCase
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

  def payload
    {
      "name" => "Saison 1", "overview" => "Début",
      "episodes" => [
        {
          "episode_number" => 1, "name" => "Bonne nouvelle", "air_date" => "2022-02-18",
          "runtime" => 57, "overview" => "Mark commence", "still_path" => "/still.jpg",
          "guest_stars" => Array.new(10) { |i| { "name" => "Invité #{i}", "character" => "Rôle #{i}" } },
          "crew" => [
            { "name" => "Ben Stiller", "job" => "Director" },
            { "name" => "Dan Erickson", "job" => "Writer" },
            { "name" => "Dan Erickson", "job" => "Screenplay" },
            { "name" => "Quelqu'un", "job" => "Gaffer" }
          ]
        },
        { "episode_number" => 2, "name" => "", "overview" => "" }
      ]
    }
  end

  test "maps the episodes of a season with synopsis, guests and crew" do
    client = FakeClient.new(payload)
    season = Tmdb::SeasonDetails.new(client: client).call(95396, 1)

    assert_equal "/tv/95396/season/1", client.calls.first.first
    assert_equal 2, season.episodes.size

    first = season.episodes.first
    assert_equal "Bonne nouvelle", first.name
    assert_equal "Mark commence", first.overview
    assert_equal 57, first.runtime_minutes
    assert_equal 8, first.guests.size
    assert_equal({ "director" => [ "Ben Stiller" ], "writer" => [ "Dan Erickson" ] }, first.crew)
  end

  test "an episode without a name or synopsis gets safe defaults" do
    episode = Tmdb::SeasonDetails.new(client: FakeClient.new(payload)).call(95396, 1).episodes.last

    assert_equal "Épisode 2", episode.name
    assert_nil episode.overview
    assert_empty episode.guests
  end

  test "rejects a non numeric id or season and a season below 1" do
    service = Tmdb::SeasonDetails.new(client: FakeClient.new({}))

    assert_raises(ArgumentError) { service.call("../x", 1) }
    assert_raises(ArgumentError) { service.call(95396, "abc") }
    assert_raises(ArgumentError) { service.call(95396, 0) }
  end
  test "the fallback episode name follows the language" do
    season = I18n.with_locale(:en) { Tmdb::SeasonDetails.new(client: FakeClient.new(payload)).call(95396, 1) }

    assert_equal "Episode 2", season.episodes.last.name
  end
end
