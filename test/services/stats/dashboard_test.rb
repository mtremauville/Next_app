require "test_helper"

class Stats::DashboardTest < ActiveSupport::TestCase
  test "counts only the user's own entries" do
    stats = Stats::Dashboard.new(users(:one))
    assert_equal users(:one).entries.count, stats.total
  end

  test "by_status returns every status" do
    assert_equal Entry.statuses.keys, Stats::Dashboard.new(users(:one)).by_status.keys
  end

  test "by_month returns the requested number of months" do
    assert_equal 6, Stats::Dashboard.new(users(:one)).by_month.size
  end

  test "marking an entry watched sets watched_at" do
    entry = entries(:severance)
    entry.update!(status: :watched)
    assert_not_nil entry.reload.watched_at
  end
end
