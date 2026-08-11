require "test_helper"

class WatchlistEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get watchlist_entries_index_url
    assert_response :success
  end

  test "should get create" do
    get watchlist_entries_create_url
    assert_response :success
  end

  test "should get update" do
    get watchlist_entries_update_url
    assert_response :success
  end

  test "should get destroy" do
    get watchlist_entries_destroy_url
    assert_response :success
  end
end
