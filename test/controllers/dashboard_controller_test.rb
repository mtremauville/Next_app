require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "shows the dashboard when signed in" do
    sign_in users(:one)
    get dashboard_path
    assert_response :success
  end

  test "redirects to sign in when signed out" do
    get dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "shows the progress of each series and the points to resume" do
    show = users(:one).entries.create!(title: "Andor", tmdb_id: 83867, media_type: "tv",
                                       episodes_total: 4, status: :watching)
    show.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched, runtime_minutes: 50)
    show.episode_progresses.create!(season_number: 1, episode_number: 2, status: :watching,
                                    position_seconds: 600, runtime_minutes: 50)
    sign_in users(:one)

    get dashboard_path

    assert_response :success
    assert_select ".nerv-series-row", text: /Andor/
    assert_select ".nerv-series-count", text: "1/4 · 25 %"
    assert_select ".nerv-resume-row", text: /Andor · S1E2/
    assert_select ".nerv-resume-row", text: /il reste 40 min/
    assert_select ".nerv-resume-row a[href=?]", series_path(83867, season: 1, anchor: "episodes")
  end

  test "has no series section when the user follows no series" do
    sign_in users(:one)
    get dashboard_path

    assert_select ".nerv-series-row", count: 0
    assert_select ".nerv-resume-row", count: 0
  end

  test "never shows another user's series" do
    users(:two).entries.create!(title: "Secret", tmdb_id: 5, media_type: "tv", episodes_total: 2)
    sign_in users(:one)

    get dashboard_path

    assert_select ".nerv-series-row", text: /Secret/, count: 0
  end
end
