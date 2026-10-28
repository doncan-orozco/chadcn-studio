require "test_helper"

class Themes::Operation::UnpublishTest < ActiveSupport::TestCase
  test "clears published_at" do
    theme = themes(:slate)

    assert Themes::Operation::Unpublish.new.call(model: theme).success?
    assert_not_predicate theme.reload, :published?
  end

  test "an unpublished theme stays unpublished" do
    assert Themes::Operation::Unpublish.new.call(model: themes(:zinc)).success?
  end
end
