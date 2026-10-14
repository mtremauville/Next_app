require "test_helper"

class GuestSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.find_or_create_by!(email: User::GUEST_EMAIL) do |user|
      user.password = "password123"
    end
  end

  test "guest login signs in the guest user and redirects to root" do
    post guest_login_url
    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end
  test "signed in user can sign out and reach the sign in page" do
    post guest_login_url
    delete destroy_user_session_url
    get new_user_session_url
    assert_response :success
  end
  test "the welcome message is shown as a toast" do
    post guest_login_url
    follow_redirect!

    assert_select ".nerv-toast[data-controller='toast'][role='status']", text: /Bienvenue/
    assert_select ".nerv-toasts[data-turbo-temporary]"
  end
  test "a message is shown once, as a toast only" do
    get entries_path
    follow_redirect!

    assert_select ".nerv-toast", count: 1
    assert_select ".nerv-flash", count: 0
  end
end
