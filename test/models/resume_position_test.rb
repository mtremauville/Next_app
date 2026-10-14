require "test_helper"

class ResumePositionTest < ActiveSupport::TestCase
  test "converts hours, minutes and seconds to seconds" do
    assert_equal 5_430, ResumePosition.parse("1", "30", "30")
  end

  test "blank fields count as zero" do
    assert_equal 2_520, ResumePosition.parse("", "42", nil)
  end

  test "rejects a position of zero" do
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("0", "0", "0") }
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("", "", "") }
  end

  test "rejects minutes or seconds of 60 or more" do
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("0", "60", "0") }
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("0", "0", "60") }
  end

  test "rejects negative and non numeric values" do
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("-1", "0", "0") }
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("1.5", "0", "0") }
    assert_raises(ResumePosition::Invalid) { ResumePosition.parse("abc", "0", "0") }
  end
end
