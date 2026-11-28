require "test_helper"

class Exports::Query::DownloadableTest < ActiveSupport::TestCase
  test "finds a draft and a published theme by slug" do
    assert_equal [ themes(:zinc) ], Exports::Query::Downloadable.call({ slug: "zinc" }).to_a
    assert_equal [ themes(:slate) ], Exports::Query::Downloadable.call({ slug: "slate" }).to_a
  end

  test "an unknown or blank slug finds nothing" do
    assert_empty Exports::Query::Downloadable.call({ slug: "nope" })
    assert_empty Exports::Query::Downloadable.call({ slug: "" })
    assert_empty Exports::Query::Downloadable.call({})
  end
end
