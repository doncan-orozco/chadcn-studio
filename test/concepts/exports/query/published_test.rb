require "test_helper"

class Exports::Query::PublishedTest < ActiveSupport::TestCase
  test "finds a published theme by slug" do
    assert_equal themes(:slate), Exports::Query::Published.call("slate")
  end

  test "a draft or unknown slug finds nothing" do
    assert_nil Exports::Query::Published.call("zinc")
    assert_nil Exports::Query::Published.call("nope")
  end
end
