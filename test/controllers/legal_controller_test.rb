require "test_helper"

class LegalControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "the terms are public" do
    get terms_path

    assert_response :success
    assert_select "h1", /Conditions générales/
  end

  test "the privacy policy is public and names the cookies" do
    get privacy_path

    assert_response :success
    assert_select "h1", /confidentialité/i
    assert_select "code", text: "_next_app_session"
  end

  test "the legal pages open for a signed in user too" do
    sign_in users(:one)
    get terms_path

    assert_response :success
  end

  test "the footer links to the legal pages and credits TMDB, signed out and signed in" do
    get new_user_session_path

    assert_select "footer.nerv-footer a[href=?]", terms_path, text: "Conditions générales"
    assert_select "footer.nerv-footer a[href=?]", privacy_path
    assert_select "footer", text: /TMDB/

    sign_in users(:one)
    get entries_path

    assert_select "footer.nerv-footer a[href=?]", terms_path
  end

  test "the privacy notice is not repeated on the legal pages" do
    get terms_path

    assert_select "dialog[data-privacy-notice-target]", count: 0
  end
  test "no placeholder is left in the legal notices" do
    [ terms_path, privacy_path ].each do |path|
      get path

      assert_no_match(/\[[A-ZÉ' ,]{6,}/, response.body, "placeholder left on #{path}")
    end
  end
end
