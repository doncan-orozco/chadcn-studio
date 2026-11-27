require "test_helper"
require "application_system_test_case"

# The tune controls are named for a screen reader and are at least 24x24 CSS px (WCAG 2.2 SC 2.5.8).
class TargetSizeTest < ApplicationSystemTestCase
  MINIMUM_TARGET_SIZE = 24

  setup { visit edit_theme_path(themes(:zinc)) }

  test "the radius slider thumb has a name and a 24 px target" do
    find(:testid, "group-radius").click
    thumb = find(:testid, "radius").find("[role=slider]")

    assert_equal "Corner radius", thumb["aria-label"]
    assert_equal "0.625rem", thumb["aria-valuetext"]
    assert_target thumb
  end

  test "the group dialog close has a 24 px target" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    assert_target find(:testid, "group-radius-panel").find("[data-slot=dialog-close]")
  end

  test "the surfaces slider thumb has a name and a 24 px target" do
    find(:testid, "group-surfaces").click
    thumb = find(:testid, "neutral-tint").find("[role=slider]")

    assert_equal "Neutral tint", thumb["aria-label"]
    assert_target thumb
  end

  test "the brand sliders are named" do
    names = %w[primary-lightness primary-chroma primary-hue].map { |id| find(:testid, id).find("[role=slider]")["aria-label"] }

    assert_equal %w[Lightness Chroma Hue], names
  end

  test "the export dialog close has a 24 px target" do
    find(:testid, "export").click

    assert_selector :testid, "export-panel"
    assert_target find(:testid, "export-panel").find("[data-slot=dialog-close]")
  end

  test "the toast close has a name and a 24 px target" do
    click_on "Save theme"
    close = find("[data-close-button]", visible: :all)

    assert_equal "Close toast", close["aria-label"]
    assert_target close
  end

  private

  # Layout size (offsetWidth/Height): an opening dialog's or toast's zoom animation does not scale it.
  def assert_target(element)
    width, height = evaluate_script("[arguments[0].offsetWidth, arguments[0].offsetHeight]", element)

    assert_operator width, :>=, MINIMUM_TARGET_SIZE, "is #{width}px wide"
    assert_operator height, :>=, MINIMUM_TARGET_SIZE, "is #{height}px tall"
  end
end
