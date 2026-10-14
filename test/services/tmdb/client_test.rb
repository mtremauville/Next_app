require "test_helper"

class Tmdb::ClientTest < ActiveSupport::TestCase
  class Spy < Tmdb::Client
    attr_reader :params

    private

    def request(_path, params)
      @params = params
      {}
    end
  end

  test "asks TMDB for the language of the current locale" do
    spy = Spy.new(token: "token")

    I18n.with_locale(:en) { spy.get("/movie/1") }
    assert_equal "en-US", spy.params[:language]

    I18n.with_locale(:fr) { spy.get("/movie/1") }
    assert_equal "fr-FR", spy.params[:language]
  end
end
