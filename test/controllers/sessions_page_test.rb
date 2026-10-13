require "test_helper"

class SessionsPageTest < ActionDispatch::IntegrationTest
  test "sign in page highlights the guest demo" do
    get new_user_session_path
    assert_response :success
    assert_select "form[action=?]", guest_login_path
    assert_select "input[type=email]"
    assert_select "input[type=password]"
  end
end
