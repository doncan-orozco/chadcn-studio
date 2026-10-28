require "test_helper"

class Themes::Query::RecentTest < ActiveSupport::TestCase
  test "lists every theme, newest first" do
    themes(:zinc).update_columns(created_at: 3.days.ago)
    themes(:slate).update_columns(created_at: 1.day.ago)
    themes(:blue).update_columns(created_at: 2.days.ago)

    assert_equal %w[slate blue zinc], Themes::Query::Recent.call.map(&:slug)
  end

  test "honors a given scope" do
    assert_equal [ "blue" ], Themes::Query::Recent.call({}, scope: Theme.where(slug: "blue")).map(&:slug)
  end
end
