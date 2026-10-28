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

  # The show presenter shares this file: its own test file is outside the item's Owns.
  def show = Themes::Presenter::Show.new(themes(:zinc))

  test "one row per variable, radius has no swatch" do
    assert_equal Chadcn::Theme::REQUIRED.size + Chadcn::Theme::ROOT_ONLY.size, show.rows.size
    radius = show.rows.find { |row| row.name == "--radius" }

    assert_nil radius.light_style
    assert_nil radius.dark_style
    assert_equal "background-color: oklch(1 0 0)", show.rows.find { |row| row.name == "--background" }.light_style
  end

  test "labels" do
    assert_equal "Edit Zinc", show.edit_label
    assert_equal "Delete Zinc", show.delete_label
  end
end
