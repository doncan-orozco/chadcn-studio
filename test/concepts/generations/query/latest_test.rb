require "test_helper"

class Generations::Query::LatestTest < ActiveSupport::TestCase
  test "lists a theme's generations newest first" do
    theme = generations(:pending).theme
    newest = theme.generations.create!(prompt: "newest")
    other = themes(:blue).generations.create!(prompt: "other theme")

    result = Generations::Query::Latest.call({ theme_id: theme.id })

    assert_equal newest, result.first
    assert_not_includes result, other
  end

  test "without a theme it lists every generation" do
    assert_equal Generation.count, Generations::Query::Latest.call.size
  end
end
