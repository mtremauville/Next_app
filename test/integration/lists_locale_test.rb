require "test_helper"

class ListsLocaleTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def english!
    patch change_locale_path, params: { locale: "en" }
  end

  test "the lists stay in French by default" do
    sign_in users(:one)
    get entries_path

    assert_select "select[aria-label='Filtrer par statut'] option", text: "Tous les statuts"
    assert_select "article.nerv-card footer", text: /Modifier/
  end

  test "the entries list is in English" do
    english!
    sign_in users(:one)
    get entries_path

    assert_select "select[aria-label='Filter by status'] option", text: "All statuses"
    assert_select "select[aria-label='Filter by genre'] option", text: "All genres"
    assert_select "article.nerv-card footer", text: /Edit/
    assert_select "article.nerv-card footer", text: /Delete/
    assert_select "article.nerv-card footer", text: /Mark as watched/
    assert_select ".nerv-card-meta", text: /Watched/
  end

  test "the home page of an empty account is in English" do
    english!
    User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
    post guest_login_url
    get root_path

    assert_select "h1", "Home"
    assert_select "h2", "Welcome to Next"
    assert_select "a", text: "[ Add the first title ]"
  end

  test "the home page of an account with titles is in English" do
    english!
    sign_in users(:one)
    get root_path

    assert_select "h2", "In progress"
    assert_select "h2", "Up next"
    assert_select "a", text: "[ See my whole list ]"
  end

  test "the playlists page is in English with pluralised counts" do
    english!
    sign_in users(:one)
    get playlists_path

    assert_select "h1", "Playlists"
    assert_select "a", text: "[ New playlist ]"
    assert_select "article.nerv-playlist .nerv-hint", text: "1 title"
    assert_select "article.nerv-playlist footer, article.nerv-playlist .nerv-actions", text: /Open/
  end

  test "counts are pluralised in French" do
    sign_in users(:one)
    get playlists_path

    assert_select ".nerv-hint", text: "1 titre"
    assert_select ".nerv-hint", text: "Aucun titre"
  end

  test "a playlist page is in English" do
    english!
    sign_in users(:one)
    get playlist_path(playlists(:sunday_movies))

    assert_select "a", text: "[ ← Playlists ]"
    assert_select "select[aria-label='Filter by status']"
    assert_select "select[data-filter-target='playlist']", count: 0
  end

  test "an empty playlist invites to add a title in English" do
    english!
    sign_in users(:one)
    get playlist_path(playlists(:empty_list))

    assert_select "p", text: "This playlist is empty."
    assert_select ".nerv-hint a", text: "[ Catalog ]"
  end

  test "the title form is translated" do
    sign_in users(:one)
    get new_entry_path
    assert_select "label", text: "Titre"
    assert_select "option", text: "Aucune"

    english!
    get new_entry_path
    assert_select "label", text: "Title"
    assert_select "label", text: "Rating (1 to 5)"
    assert_select "option", text: "None"
    assert_select "option", text: "To watch"
  end

  test "validation errors name the fields in the chosen language" do
    sign_in users(:one)
    post entries_path, params: { entry: { title: "", status: "to_watch" } }
    assert_select ".nerv-errors p", text: /Titre/

    english!
    post entries_path, params: { entry: { title: "", status: "to_watch" } }
    assert_select ".nerv-errors p", text: /Title/
  end

  test "the statistics page is in English with named months" do
    english!
    sign_in users(:one)
    get dashboard_path

    assert_select "h1", "Statistics"
    assert_select "h2", "Estimated time"
    assert_select "h2", "Watched per month"
    assert_select ".nerv-bar-label", text: /#{Date.current.strftime("%B %Y")}/
  end

  test "the statistics page shows French month names" do
    sign_in users(:one)
    get dashboard_path

    assert_select ".nerv-bar-label", text: /#{I18n.l(Date.current, format: :month_year, locale: :fr)}/
  end

  test "the resume text follows the language" do
    users(:one).entries.create!(title: "Dune", media_type: "movie", status: :watching, position_seconds: 2_520)
    sign_in users(:one)

    get entries_path
    assert_select ".nerv-card-resume", text: "Reprendre à 42 min"

    english!
    get entries_path
    assert_select ".nerv-card-resume", text: "Resume at 42 min"
  end
end
