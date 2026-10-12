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
end
