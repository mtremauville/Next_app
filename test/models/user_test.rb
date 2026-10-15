require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "only the demo account is a guest" do
    assert User.new(email: User::GUEST_EMAIL).guest?
    assert_not users(:one).guest?
  end
end
