require "test_helper"

class PlaylistTest < ActiveSupport::TestCase
  test "is valid with a name and a user" do
    assert Playlist.new(name: "Séries", user: users(:one)).valid?
  end

  test "requires a name" do
    playlist = Playlist.new(user: users(:one))
    assert_not playlist.valid?
    assert_includes playlist.errors[:name], I18n.t("errors.messages.blank")
  end

  test "name is unique per user" do
    playlist = Playlist.new(name: "Films du dimanche", user: users(:one))
    assert_not playlist.valid?
  end

  test "same name is allowed for another user" do
    assert Playlist.new(name: "Films du dimanche", user: users(:two)).valid?
  end

  test "destroying a playlist keeps its entries" do
    playlist = playlists(:sunday_movies)
    entry = entries(:inception)

    playlist.destroy
    assert_nil entry.reload.playlist_id
  end
end
