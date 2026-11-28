require "test_helper"

class Exports::Query::PublishedTest < ActiveSupport::TestCase
  test "finds a published theme by slug" do
    assert_equal [ themes(:slate) ], Exports::Query::Published.call({ slug: "slate" }).to_a
  end

  test "a draft or unknown slug finds nothing" do
    assert_empty Exports::Query::Published.call({ slug: "zinc" })
    assert_empty Exports::Query::Published.call({ slug: "nope" })
  end

  test "a blank slug finds nothing" do
    assert_empty Exports::Query::Published.call({ slug: "" })
    assert_empty Exports::Query::Published.call({})
  end

  test "include_drafts lets a draft through and still needs its slug" do
    assert_equal [ themes(:zinc) ], Exports::Query::Published.call({ slug: "zinc", include_drafts: true }).to_a
    assert_empty Exports::Query::Published.call({ slug: "", include_drafts: true })
  end
end
