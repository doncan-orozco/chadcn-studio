require "test_helper"

class Themes::Presenter::ListTest < ActiveSupport::TestCase
  BASE = "http://example.test"

  test "names the page in the browser title" do
    assert_equal "Themes - Chadcn Studio", Themes::Presenter::List.new([], base_url: BASE).document_title
  end

  test "wraps each theme in a card and counts them" do
    list = Themes::Presenter::List.new(Theme.order(:slug), base_url: BASE)

    assert_equal 3, list.cards.size
    assert_instance_of Themes::Presenter::Card, list.cards.first
    assert_equal "3 themes, newest first.", list.summary
    refute_predicate list, :empty?
  end

  test "an empty list says so" do
    list = Themes::Presenter::List.new(Theme.none, base_url: BASE)

    assert_predicate list, :empty?
    assert_equal "No themes yet.", list.summary
  end

  test "New theme is the primary whether or not themes exist" do
    assert_equal "default", Themes::Presenter::List.new(Theme.all, base_url: BASE).new_theme_variant
    assert_equal "default", Themes::Presenter::List.new(Theme.none, base_url: BASE).new_theme_variant
  end

  test "the intro mentions describing only when generation is configured" do
    assert_includes Themes::Presenter::List.new(Theme.all, configured: true, base_url: BASE).intro, "describe a theme"
    assert_equal "Pick a color and get a whole shadcn theme.", Themes::Presenter::List.new(Theme.all, configured: false, base_url: BASE).intro
  end

  test "describing a theme is offered only when generation is configured" do
    assert_predicate Themes::Presenter::List.new(Theme.all, configured: true, base_url: BASE), :describable?
    refute_predicate Themes::Presenter::List.new(Theme.all, configured: false, base_url: BASE), :describable?
  end

  test "one theme is singular" do
    assert_equal "1 theme, newest first.", Themes::Presenter::List.new(Theme.where(slug: "zinc"), base_url: BASE).summary
  end
end
