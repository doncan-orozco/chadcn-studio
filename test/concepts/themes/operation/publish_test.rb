require "test_helper"

class Themes::Operation::PublishTest < ActiveSupport::TestCase
  test "sets published_at" do
    theme = themes(:zinc)

    assert_predicate Themes::Operation::Publish.new.call(model: theme), :success?
    assert_predicate theme.reload, :published?
  end

  test "publishing again keeps the first publication time" do
    theme = themes(:slate)
    first = theme.published_at

    Themes::Operation::Publish.new.call(model: theme)

    assert_equal first, theme.reload.published_at
  end

  test "an invalid theme fails with :invalid and stays a draft" do
    theme = themes(:zinc)
    theme.light = theme.light.except("primary")

    result = Themes::Operation::Publish.new.call(model: theme)

    assert_equal :invalid, result.failure[:code]
    assert_not_predicate Theme.find(theme.id), :published?
  end
end
