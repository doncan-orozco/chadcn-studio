require "test_helper"

class Themes::Presenter::CardTest < ActiveSupport::TestCase
  setup { @card = Themes::Presenter::Card.new(themes(:blue)) }

  test "swatches are the primary, secondary, accent and five chart colors, styled from validated oklch" do
    assert_equal Themes::Presenter::Card::SWATCHES, @card.swatches.map(&:name)
    assert_equal "background-color: oklch(0.488 0.243 264.376)", @card.swatches.first.style
  end

  test "a stored value that is not a color never reaches a style attribute and does not fail the list" do
    theme = themes(:blue)
    theme.light = theme.light.merge("primary" => "red; background: url(x)")
    card = Themes::Presenter::Card.new(theme)

    refute_includes card.swatches.map(&:name), "primary"
    assert_empty(card.swatches.reject { |swatch| swatch.style.match?(/\Abackground-color: oklch\([\d. ]+\)\z/) })
  end

  test "badge variant and edit label" do
    assert_equal "secondary", @card.badge_variant
    assert_equal "default", Themes::Presenter::Card.new(themes(:slate)).badge_variant
    assert_equal "Edit Blue", @card.edit_label
  end

  test "paths, status and date" do
    assert_equal "/themes/#{themes(:blue).id}", @card.path
    assert_equal "/themes/#{themes(:blue).id}/edit", @card.edit_path
    assert_equal "Draft", @card.status_label
    assert_equal "Published", Themes::Presenter::Card.new(themes(:slate)).status_label
    assert_match(/\ACreated \w+ \d+, \d{4}\z/, @card.created_label)
  end
end
