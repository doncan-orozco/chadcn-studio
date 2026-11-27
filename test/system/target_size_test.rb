require "test_helper"
require "application_system_test_case"

# The tune controls are named for a screen reader and are at least 24x24 CSS px (WCAG 2.2 SC 2.5.8).
class TargetSizeTest < ApplicationSystemTestCase
  MIN = 24

  # Layout size (offsetWidth), which an opening dialog's or toast's zoom animation does not scale. The first visible match: a slider also renders hidden twins (the bubble input) that measure 0x0.
  def assert_target(selector)
    width, height = evaluate_script(<<~JS)
      (() => {
        const box = [...document.querySelectorAll(#{selector.to_json})].map((el) => ({ width: el.offsetWidth, height: el.offsetHeight })).find((r) => r.width > 0)
        return box ? [box.width, box.height] : [0, 0]
      })()
    JS

    assert_operator width, :>=, MIN, "#{selector} is #{width}px wide"
    assert_operator height, :>=, MIN, "#{selector} is #{height}px tall"
  end

  test "the radius slider thumb has a name and a 24 px target" do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "group-radius").click
    thumb = find(:testid, "radius").find("[role=slider]")

    assert_equal "Corner radius", thumb["aria-label"]
    assert_equal "0.625rem", thumb["aria-valuetext"]
    assert_target "[data-testid=radius] [role=slider]"
    assert_target "[data-testid=group-radius-panel] [data-slot=dialog-close]"
  end

  test "the surfaces slider thumb has a name and a 24 px target" do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "group-surfaces").click
    thumb = find(:testid, "neutral-tint").find("[role=slider]")

    assert_equal "Neutral tint", thumb["aria-label"]
    assert_target "[data-testid=neutral-tint] [role=slider]"
  end

  test "the brand sliders are named" do
    visit edit_theme_path(themes(:zinc))

    assert_equal %w[Chroma Hue Lightness], all("[data-testid^=primary-] [role=slider]", visible: :all).map { |thumb| thumb["aria-label"] }.sort
  end

  test "the export dialog close has a 24 px target" do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "export").click

    assert_selector :testid, "export-panel"
    assert_target "[data-testid=export-panel] [data-slot=dialog-close]"
  end

  test "the toast close has a name and a 24 px target" do
    visit edit_theme_path(themes(:zinc))
    click_on "Save theme"

    assert_selector "[data-close-button]", visible: :all
    assert_equal "Close toast", find("[data-close-button]", visible: :all)["aria-label"]
    assert_target "[data-close-button]"
  end
end
