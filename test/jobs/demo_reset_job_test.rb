require "test_helper"
require "minitest/mock"

class DemoResetJobTest < ActiveJob::TestCase
  class Spy
    attr_reader :calls

    def initialize(error: nil)
      @calls = 0
      @error = error
    end

    def call
      @calls += 1
      raise @error if @error
    end
  end

  setup do
    @guest = User.find_or_create_by!(email: User::GUEST_EMAIL) { |user| user.password = "password123" }
    @guest.entries.destroy_all
    @guest.playlists.destroy_all
  end

  def run_job(spy)
    Demo::Reset.stub :new, ->(*) { spy } do
      DemoResetJob.perform_now
    end
  end

  test "resets an empty guest account" do
    spy = Spy.new
    run_job(spy)

    assert_equal 1, spy.calls
  end

  test "resets an account that has been idle" do
    @guest.entries.create!(title: "Ancien", updated_at: 2.hours.ago)
    spy = Spy.new
    run_job(spy)

    assert_equal 1, spy.calls
  end

  test "waits while a visitor is active" do
    @guest.entries.create!(title: "Récent")
    spy = Spy.new
    run_job(spy)

    assert_equal 0, spy.calls
  end

  test "activity on episodes also counts" do
    entry = @guest.entries.create!(title: "Série", media_type: "tv", updated_at: 2.hours.ago)
    entry.episode_progresses.create!(season_number: 1, episode_number: 1, status: :watched)
    spy = Spy.new
    run_job(spy)

    assert_equal 0, spy.calls
  end

  test "does nothing when there is no guest account" do
    @guest.destroy!
    spy = Spy.new
    run_job(spy)

    assert_equal 0, spy.calls
  end

  test "an unavailable TMDB does not fail the job" do
    spy = Spy.new(error: Tmdb::Error.new("down"))

    assert_nothing_raised { run_job(spy) }
  end
end
