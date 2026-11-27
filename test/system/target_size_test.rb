require "test_helper"
require "application_system_test_case"

# What #181/#182 do not cover on the tune pages: every slider thumb is named for a screen reader, and the toast close
# (sized by app CSS, the gem has no option for it) is at least 24x24 CSS px (WCAG 2.2 SC 2.5.8).
class TargetSizeTest < ApplicationSystemTestCase
  MINIMUM_TARGET_SIZE = 24

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

  test "the toast close has a name and a 24 px target" do
    click_on "Save theme"
    close = find("[data-close-button]", visible: :all)
    # Layout size (offsetWidth/Height): the toast's enter animation does not scale it.
    width, height = evaluate_script("[arguments[0].offsetWidth, arguments[0].offsetHeight]", close)

    assert_equal "Close toast", close["aria-label"]
    assert_operator width, :>=, MINIMUM_TARGET_SIZE
    assert_operator height, :>=, MINIMUM_TARGET_SIZE
  end
end
