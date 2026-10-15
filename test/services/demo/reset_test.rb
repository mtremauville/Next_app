require "test_helper"

class Demo::ResetTest < ActiveSupport::TestCase
  class FakeTitles
    def call(media_type, id)
      seasons = if media_type == "tv"
        [ Tmdb::TitleDetails::Season.new(number: 1, name: "Saison 1", episode_count: 9),
          Tmdb::TitleDetails::Season.new(number: 2, name: "Saison 2", episode_count: 8) ]
      else
        []
      end

      Tmdb::TitleDetails::Result.new(
        tmdb_id: id.to_i, media_type: media_type, title: "Titre #{id}", year: "2020",
        poster_path: "/p#{id}.jpg", overview: "Synopsis", genres: [ "Drame" ],
        runtime_minutes: 120, seasons: seasons
      )
    end
  end

  class FakeSeasons
    def call(_id, number)
      episodes = (1..12).map do |n|
        Tmdb::SeasonDetails::Episode.new(number: n, name: "Épisode #{n}", runtime_minutes: 50, guests: [], crew: {})
      end
      Tmdb::SeasonDetails::Result.new(season_number: number.to_i, name: "Saison #{number}", episodes: episodes)
    end
  end

  class DownTitles
    def call(*) = raise(Tmdb::Error, "down")
  end

  setup do
    @guest = User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
  end

  def reset(user = @guest, titles: FakeTitles.new)
    Demo::Reset.new(user, title_details: titles, season_details: FakeSeasons.new).call
  end

  test "builds the sample playlists and titles" do
    reset

    assert_equal Demo::Reset::PLAYLISTS.sort, @guest.playlists.pluck(:name).sort
    assert_equal Demo::Reset::MOVIES.size + Demo::Reset::SERIES.size, @guest.entries.count
  end

  test "replaces whatever the guest account contained" do
    @guest.playlists.create!(name: "Bidon")
    @guest.entries.create!(title: "Données d'un visiteur")

    reset

    assert_not @guest.entries.exists?(title: "Données d'un visiteur")
    assert_not @guest.playlists.exists?(name: "Bidon")
  end

  test "never touches another user's data" do
    before = [ users(:one).entries.count, users(:one).playlists.count ]

    reset

    assert_equal before, [ users(:one).entries.count, users(:one).playlists.count ]
  end

  test "running it twice gives the same result" do
    reset
    first = [ @guest.entries.count, @guest.playlists.count, EpisodeProgress.count ]

    reset

    assert_equal first, [ @guest.entries.count, @guest.playlists.count, EpisodeProgress.count ]
  end

  test "restores the movies with their status, rating, position and watch date" do
    reset

    inception = @guest.entries.find_by!(tmdb_id: 27205)
    assert inception.watched?
    assert_equal 5, inception.rating
    assert_in_delta 40.days.ago, inception.watched_at, 1.minute

    interstellar = @guest.entries.find_by!(tmdb_id: 157336)
    assert interstellar.watching?
    assert_equal 4_320, interstellar.position_seconds

    assert @guest.entries.find_by!(tmdb_id: 496243).to_watch?
    assert_equal "Films du dimanche", inception.playlist.name
  end

  test "restores the series progress, the finished season and the resume point" do
    reset

    severance = @guest.entries.find_by!(tmdb_id: 95396)
    assert severance.watching?
    assert_equal 17, severance.episodes_total
    assert_equal 6, severance.episode_progresses.watched.count

    resume = severance.episode_progresses.find_by!(season_number: 1, episode_number: 7)
    assert resume.watching?
    assert_equal 1_500, resume.position_seconds

    arcane = @guest.entries.find_by!(tmdb_id: 94605)
    assert_equal 9, arcane.episode_progresses.watched.count
    assert arcane.watching?, "a series with one finished season out of two is in progress"

    assert @guest.entries.find_by!(tmdb_id: 83867).to_watch?
  end

  test "keeps the current data when TMDB is unavailable" do
    @guest.entries.create!(title: "À conserver")

    assert_raises(Tmdb::Error) { reset(titles: DownTitles.new) }

    assert @guest.entries.exists?(title: "À conserver")
  end
end
