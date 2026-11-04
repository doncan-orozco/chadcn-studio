require "test_helper"

class Generations::Query::InWindowTest < ActiveSupport::TestCase
  test "lists the generations created since the given time, across themes" do
    old = themes(:blue).generations.create!(prompt: "old")
    old.update_columns(created_at: 2.hours.ago)
    recent = themes(:blue).generations.create!(prompt: "recent")

    result = Generations::Query::InWindow.call({ since: 1.hour.ago })

    assert_includes result, recent
    assert_includes result, generations(:pending)
    assert_not_includes result, old
  end

  test "without a start it lists every generation" do
    assert_equal Generation.count, Generations::Query::InWindow.call.size
  end
end
