require "test_helper"

class LocaleTest < ActionDispatch::IntegrationTest
  setup do
    User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
  end

  test "the app is in French by default" do
    get new_user_session_path

    assert_select "html[lang=fr]"
    assert_select "h2", text: "Connexion"
  end

  test "the sign-in page offers both languages" do
    get new_user_session_path

    assert_select "nav.nerv-locale button[lang=fr]"
    assert_select "nav.nerv-locale button[lang=en]"
  end

  test "switching language stores a cookie and goes back to the page" do
    patch change_locale_path, params: { locale: "en" }, headers: { "HTTP_REFERER" => new_user_session_url }

    assert_redirected_to new_user_session_url
    assert_equal "en", cookies[:locale]

    follow_redirect!

    assert_select "html[lang=en]"
    assert_select "h2", text: "Sign in"
    assert_select "button[lang=en][aria-pressed=true]"
  end

  test "an unsupported language is ignored" do
    patch change_locale_path, params: { locale: "de" }

    assert_nil cookies[:locale]
    get new_user_session_path

    assert_select "html[lang=fr]"
  end

  test "the browser language is used when there is no cookie" do
    get new_user_session_path, headers: { "Accept-Language" => "en-US,en;q=0.9" }

    assert_select "html[lang=en]"
  end

  test "an unsupported browser language falls back to French" do
    get new_user_session_path, headers: { "Accept-Language" => "de-DE,de;q=0.9" }

    assert_select "html[lang=fr]"
  end

  test "the cookie wins over the browser language" do
    patch change_locale_path, params: { locale: "fr" }
    get new_user_session_path, headers: { "Accept-Language" => "en-US" }

    assert_select "html[lang=fr]"
  end

  test "the message of the sign-in redirection follows the chosen language" do
    patch change_locale_path, params: { locale: "en" }
    get entries_path

    assert_redirected_to new_user_session_path
    assert_equal I18n.t("devise.failure.unauthenticated", locale: :en), flash[:alert]
  end

  test "controller messages follow the chosen language" do
    patch change_locale_path, params: { locale: "en" }
    post guest_login_url

    assert_equal I18n.t("flash.guest_welcome", locale: :en), flash[:notice]
  end

  test "the footer and the navigation are translated" do
    patch change_locale_path, params: { locale: "en" }
    post guest_login_url
    get entries_path

    assert_select "footer a", text: "Terms of use"
    assert_select "nav#main-nav a", text: "[ My list ]"
  end
end
