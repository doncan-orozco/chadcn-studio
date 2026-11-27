require "test_helper"
require "application_system_test_case"

# What the hit-area work (#181, #182, #226) does not assert on the tune pages: every slider thumb and the toast close are
# named for a screen reader.
class TargetSizeTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "the radius slider thumb reads its name and value" do
    find(:testid, "group-radius").click
    thumb = find(:testid, "radius").find("[role=slider]")

    assert_equal "Corner radius", thumb["aria-label"]
    assert_equal "0.625rem", thumb["aria-valuetext"]
  end

  test "the surfaces slider thumb reads its name" do
    find(:testid, "group-surfaces").click

    assert_equal "Neutral tint", find(:testid, "neutral-tint").find("[role=slider]")["aria-label"]
  end

  test "the brand slider thumbs are named" do
    names = %w[primary-lightness primary-chroma primary-hue].map { |id| find(:testid, id).find("[role=slider]")["aria-label"] }

    assert_equal %w[Lightness Chroma Hue], names
  end

  test "the toast close is named" do
    click_on "Save theme"

    assert_equal "Close toast", find("[data-close-button]", visible: :all)["aria-label"]
  end
end
