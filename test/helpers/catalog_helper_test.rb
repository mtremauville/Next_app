require "test_helper"

class CatalogHelperTest < ActionView::TestCase
  test "air dates follow the locale" do
    assert_equal "18/02/2022", I18n.with_locale(:fr) { format_air_date("2022-02-18") }
    assert_equal "February 18, 2022", I18n.with_locale(:en) { format_air_date("2022-02-18") }
  end

  test "an invalid air date gives nothing" do
    assert_nil format_air_date(nil)
    assert_nil format_air_date("pas une date")
  end

  test "crew labels are translated" do
    assert_equal "Réalisation", I18n.with_locale(:fr) { crew_label("director") }
    assert_equal "Director", I18n.with_locale(:en) { crew_label("director") }
  end
end
