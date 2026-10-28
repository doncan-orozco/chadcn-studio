require "test_helper"

class Themes::Presenter::ListTest < ActiveSupport::TestCase
  test "wraps each theme in a card and counts them" do
    list = Themes::Presenter::List.new(Theme.order(:slug))

    assert_equal 3, list.cards.size
    assert_instance_of Themes::Presenter::Card, list.cards.first
    assert_equal "3 themes, newest first.", list.summary
    refute_predicate list, :empty?
  end

  test "an empty list says so" do
    list = Themes::Presenter::List.new(Theme.none)

    assert_predicate list, :empty?
    assert_equal "No themes yet.", list.summary
  end

  test "one theme is singular" do
    assert_equal "1 theme, newest first.", Themes::Presenter::List.new(Theme.where(slug: "zinc")).summary
  end
end
