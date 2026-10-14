require "test_helper"
require "minitest/mock"

class SeriesProgressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TitleSource = Struct.new(:result) do
    def call(*) = result
  end

  SeasonSource = Struct.new(:result) do
    def call(*) = result
  end

  setup { sign_in users(:one) }

  def title
    Tmdb::TitleDetails::Result.new(
      tmdb_id: 95396, media_type: "tv", title: "Severance", year: "2022", genres: [],
      seasons: [ Tmdb::TitleDetails::Season.new(number: 1, name: "Saison 1", episode_count: 2) ]
    )
  end

  def season
    episodes = [ 1, 2 ].map do |number|
      Tmdb::SeasonDetails::Episode.new(number: number, name: "Épisode #{number}", runtime_minutes: 50, guests: [], crew: {})
    end
    Tmdb::SeasonDetails::Result.new(season_number: 1, name: "Saison 1", episodes: episodes)
  end

  def patch_with(path, params = {})
    Tmdb::TitleDetails.stub :new, ->(*) { TitleSource.new(title) } do
      Tmdb::SeasonDetails.stub :new, ->(*) { SeasonSource.new(season) } do
        patch path, params: params
      end
    end
  end

  def episode_path(number)
    series_episode_progress_path(tmdb_id: 95396, season: 1, episode: number)
  end

  test "marks an episode as watched and goes back to the series page" do
    assert_difference "EpisodeProgress.count", 1 do
      patch_with episode_path(1), { status: "watched" }
    end

    assert_redirected_to series_path(95396)
    assert users(:one).entries.find_by!(tmdb_id: 95396).watching?
  end

  test "marks a whole season" do
    assert_difference "EpisodeProgress.count", 2 do
      patch_with series_season_progress_path(tmdb_id: 95396, season: 1), { status: "watched" }
    end

    assert users(:one).entries.find_by!(tmdb_id: 95396).watched?
  end

  test "an unknown status creates nothing" do
    assert_no_difference [ "Entry.count", "EpisodeProgress.count" ] do
      patch_with episode_path(1), { status: "garbage" }
    end

    assert_equal "Statut inconnu.", flash[:alert]
  end

  test "an unknown episode creates nothing" do
    assert_no_difference [ "Entry.count", "EpisodeProgress.count" ] do
      patch_with episode_path(99), { status: "watched" }
    end

    assert_equal "Épisode introuvable.", flash[:alert]
  end

  test "reports that TMDB is unavailable" do
    Tmdb::TitleDetails.stub :new, ->(*) { raise Tmdb::Error, "down" } do
      patch episode_path(1), params: { status: "watched" }
    end

    assert_redirected_to series_path(95396)
    assert_match(/TMDB est indisponible/, flash[:alert])
  end

  test "redirects to sign in when signed out" do
    sign_out :user
    patch_with episode_path(1), { status: "watched" }

    assert_redirected_to new_user_session_path
  end
end
