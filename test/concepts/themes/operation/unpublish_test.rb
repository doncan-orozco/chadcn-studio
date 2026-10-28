require "test_helper"

class Themes::Operation::UnpublishTest < ActiveSupport::TestCase
  test "clears published_at" do
    theme = themes(:slate)

    assert_predicate Themes::Operation::Unpublish.new.call(model: theme), :success?
    assert_not_predicate theme.reload, :published?
  end

  test "an unpublished theme stays unpublished" do
    assert_predicate Themes::Operation::Unpublish.new.call(model: themes(:zinc)), :success?
  end

  test "an invalid theme fails with :invalid and stays published" do
    theme = themes(:slate)
    first = theme.published_at
    theme.light = theme.light.except("primary")

    result = Themes::Operation::Unpublish.new.call(model: theme)

    assert_equal :invalid, result.failure[:code]
    assert_equal first, theme.published_at
    assert_predicate Theme.find(theme.id), :published?
  end
end
