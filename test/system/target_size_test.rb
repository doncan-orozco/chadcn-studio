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

  # The box the audit measures is the element's own, so an `::after` overlay does not count; the layout size is read, since
  # a panel opening still scales (zoom-in-95) and its bounding rect with it.
  test "every small control measures at least 24 x 24 on its own box" do
    find(:testid, "group-radius").click
    undersized = page.evaluate_script(<<~JS)
      [...document.querySelectorAll("[role=slider], [role=switch], [data-slot=dialog-close]:has(.sr-only), [data-close-button]")]
        .filter((el) => el.checkVisibility())
        .filter((el) => el.offsetWidth < 24 || el.offsetHeight < 24)
        .map((el) => `${el.getAttribute("aria-label") || el.textContent.trim()} ${el.offsetWidth}x${el.offsetHeight}`)
    JS

    assert_empty undersized
  end

  test "the Close of a panel measures 24 x 24" do
    find(:testid, "group-radius").click
    close = find(:testid, "group-radius-panel").find("[data-slot=dialog-close]", text: "Close")

    assert_operator close.evaluate_script("this.offsetWidth"), :>=, 24
    assert_operator close.evaluate_script("this.offsetHeight"), :>=, 24
  end

  test "the toast close measures 24 x 24" do
    click_on "Save theme"
    box = find("[data-close-button]", visible: :all).evaluate_script("this.getBoundingClientRect().toJSON()")

    assert_operator box["width"], :>=, 24
    assert_operator box["height"], :>=, 24
  end
end
