require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @guest = User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
  end

  test "the demo account cannot open its account page" do
    post guest_login_url
    get edit_user_registration_path

    assert_redirected_to root_path
  end

  test "the demo account cannot change its email" do
    post guest_login_url
    patch user_registration_path, params: { user: { email: "autre@example.com", current_password: "password123" } }

    assert_redirected_to root_path
    assert_equal User::GUEST_EMAIL, @guest.reload.email
  end

  test "the demo account cannot be deleted" do
    post guest_login_url
    delete user_registration_path

    assert User.exists?(email: User::GUEST_EMAIL)
  end

  test "a regular user can still open the account page" do
    sign_in users(:one)
    get edit_user_registration_path

    assert_response :success
  end
end
