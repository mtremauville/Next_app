require "test_helper"

class SideMenuTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def active_links
    css_select("nav#side-menu a.is-active").map { |link| link.text.strip }
  end

  test "a signed out visitor has no menu" do
    get new_user_session_path

    assert_select "nav#side-menu", count: 0
    assert_select "button[aria-controls='side-menu']", count: 0
    assert_select ".nerv-shell--no-menu"
    assert_select "header a.nerv-logo"
  end

  test "a signed in user has the side menu, its toggle and its backdrop" do
    sign_in users(:one)
    get entries_path

    assert_select "[data-controller~='side-menu']"
    assert_select "header button[aria-controls='side-menu'][aria-expanded]"
    assert_select "nav#side-menu[aria-label='Navigation principale']"
    assert_select ".nerv-side-backdrop[hidden]"
    assert_select ".nerv-content[data-side-menu-target='inert']", count: 1
    assert_select "[data-controller~='nav']", count: 0
  end

  test "the menu lists every section and a sign out button" do
    sign_in users(:one)
    get entries_path

    [ root_path, entries_path, playlists_path, catalog_path, dashboard_path, new_entry_path ].each do |path|
      assert_select "nav#side-menu a[href=?]", path
    end
    assert_select "nav#side-menu form[action=?]", destroy_user_session_path
  end

  test "the current section is highlighted, once" do
    sign_in users(:one)

    get entries_path
    assert_equal [ "[ Ma liste ]" ], active_links
    assert_select "nav#side-menu a[aria-current='page']", count: 1

    get edit_entry_path(entries(:inception))
    assert_equal [ "[ Ma liste ]" ], active_links

    get new_entry_path
    assert_equal [ "[ Nouveau titre ]" ], active_links

    get playlists_path
    assert_equal [ "[ Playlists ]" ], active_links

    get dashboard_path
    assert_equal [ "[ Statistiques ]" ], active_links

    get root_path
    assert_equal [ "[ Accueil ]" ], active_links
  end

  test "the menu follows the chosen language" do
    sign_in users(:one)
    patch change_locale_path, params: { locale: "en" }
    get entries_path

    assert_select "nav#side-menu[aria-label='Main navigation']"
    assert_select "nav#side-menu a", text: "[ My list ]"
    assert_select "nav#side-menu button", text: "[ Sign out ]"
  end

  test "the menu is closed when the page loads" do
    sign_in users(:one)
    get entries_path

    assert_select "button[aria-controls='side-menu'][aria-expanded='false']"
    assert_select "nav#side-menu:not(.is-open)"
    assert_select ".nerv-side-backdrop[hidden]"
    assert_not_includes response.body, "next:side-menu"
  end
  test "signing out asks for a confirmation" do
    sign_in users(:one)
    get entries_path

    assert_select "nav#side-menu [data-controller='confirm-modal']" do
      assert_select "button[data-action='confirm-modal#open']", text: "[ Déconnexion ]"
      assert_select "dialog h2", "Se déconnecter ?"
      assert_select "dialog form[action=?]", destroy_user_session_path
      assert_select "dialog input[name='_method'][value='delete']"
    end
  end

  test "the sign out confirmation is translated" do
    sign_in users(:one)
    patch change_locale_path, params: { locale: "en" }
    get entries_path

    assert_select "dialog h2", "Sign out?"
    assert_select "dialog button", text: "[ Sign out ]"
  end

  test "the confirmation really signs the user out" do
    sign_in users(:one)

    delete destroy_user_session_path
    assert_redirected_to root_path

    get entries_path
    assert_redirected_to new_user_session_path
  end
end
