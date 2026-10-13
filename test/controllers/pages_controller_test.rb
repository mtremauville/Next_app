require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get home when signed in" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  test "should redirect to sign in when signed out" do
    get root_url
    assert_redirected_to new_user_session_url
  end

  test "home shows the in-progress and up-next titles of the user" do
    sign_in users(:one)
    get root_url
    assert_response :success
    assert_select ".nerv-mini strong", text: "Severance"
  end

  test "home never shows another user's titles" do
    sign_in users(:one)
    get root_url
    assert_select ".nerv-mini strong", text: "Titre privé", count: 0
  end

  test "home invites a user without entries to add the first title" do
    users(:two).entries.destroy_all
    sign_in users(:two)
    get root_url
    assert_select "a", text: "[ Ajouter le premier titre ]"
  end
end
