require "test_helper"

class LegalLocaleTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def english!
    patch change_locale_path, params: { locale: "en" }
  end

  test "the terms are in English with their nine sections" do
    english!
    get terms_path

    assert_select "h1", "Terms of use"
    assert_select "article.nerv-legal h2", 9
    assert_select "a[href=?]", privacy_path, text: "privacy policy"
  end

  test "the terms keep nine sections in French" do
    get terms_path

    assert_select "h1", "Conditions générales d'utilisation"
    assert_select "article.nerv-legal h2", 9
  end

  test "the privacy policy is in English and lists the cookies" do
    english!
    get privacy_path

    assert_select "h1", "Privacy policy"
    assert_select "article.nerv-legal h2", 9
    assert_select "code", text: "_next_app_session"
    assert_select "code", text: "locale"
    assert_select "li", text: /#{I18n.t("legal.days", count: LegalHelper::PUBLISHER[:log_retention_days], locale: :en)}/
  end

  test "the log retention is spelled in each language" do
    get privacy_path
    assert_select "li", text: /#{LegalHelper::PUBLISHER[:log_retention_days]} jours/
  end

  test "the publisher's details are shown in both languages" do
    [ :fr, :en ].each do |locale|
      patch change_locale_path, params: { locale: locale.to_s }
      get privacy_path

      assert_select "article", text: /#{Regexp.escape(LegalHelper::PUBLISHER[:contact])}/
    end
  end

  test "no placeholder is left in the English legal text either" do
    english!

    [ terms_path, privacy_path ].each do |path|
      get path

      assert_no_match(/\[[A-ZÉ' ,]{6,}/, response.body, "placeholder left on #{path}")
    end
  end

  test "the sign-up page is translated" do
    get new_user_registration_path
    assert_select "h2", "Créer un compte"
    assert_select "label", text: /Confirmation du mot de passe/

    english!
    get new_user_registration_path
    assert_select "h2", "Create an account"
    assert_select "label", text: /Password confirmation/
    assert_select "input[type=submit][value='[ Create my account ]']"
  end

  test "sign-up errors are in the chosen language" do
    english!
    post user_registration_path, params: { user: { email: "", password: "" } }

    assert_response :unprocessable_entity
    assert_select ".nerv-errors", text: /#{Regexp.escape(I18n.t("errors.messages.blank", locale: :en))}/

    patch change_locale_path, params: { locale: "fr" }
    post user_registration_path, params: { user: { email: "", password: "" } }

    assert_select ".nerv-errors", text: /#{Regexp.escape(I18n.t("errors.messages.blank", locale: :fr))}/
  end

  test "the account page is translated and offers to delete the account" do
    sign_in users(:one)
    get edit_user_registration_path
    assert_select "h2", "Mon compte"

    english!
    get edit_user_registration_path
    assert_select "h2", "My account"
    assert_select "button", text: "[ Delete my account ]"
    assert_select "label", text: /Current password/
  end

  test "the account link is hidden from the demo account" do
    User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
    post guest_login_url
    get root_path

    assert_select "nav#main-nav a[href=?]", edit_user_registration_path, count: 0
  end

  test "a regular user sees the account link" do
    sign_in users(:one)
    get root_path

    assert_select "nav#main-nav a[href=?]", edit_user_registration_path
  end
  test "there is no forgotten password link, since no email can be sent" do
    get new_user_session_path

    assert_select "a", text: /Mot de passe oublié/, count: 0

    english!
    get new_user_session_path

    assert_select "a", text: /Forgot your password/, count: 0
  end
end
