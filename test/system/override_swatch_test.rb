require "application_system_test_case"

class OverrideSwatchTest < ApplicationSystemTestCase
  setup do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "group-advanced").click
  end

  test "a typed hex colors the swatch before it is committed" do
    override_field.send_keys("#ff0000")

    assert_equal "typed", swatch["data-state"]
    assert_match(/\A(rgb\(255, 0, 0\)|color\(srgb 1 0 0\))\z/, swatch.style("background-color")["background-color"])
  end

  test "a half-typed hex shows the derived color, not a stale one" do
    derived = swatch[:style]
    override_field.send_keys("#ff0000", :backspace)

    assert_equal "invalid", swatch["data-state"]
    assert_equal derived, swatch[:style]
  end

  test "clearing the field returns the swatch to the derived color" do
    derived = swatch[:style]
    override_field.send_keys("#ff0000", *Array.new(7, :backspace))

    assert_equal "derived", swatch["data-state"]
    assert_equal derived, swatch[:style]
  end

  test "closing the panel keeps what was typed" do
    find_field("override-light-border").send_keys("#9ca3af")
    find(:testid, "group-advanced-panel").send_keys(:escape)
    find(:testid, "group-advanced").click

    assert_field "override-light-border", with: /#9ca3af|oklch\(0\.71/
  end

  private

  def override_row = find(:testid, "override-row", match: :first)
  def override_field = override_row.find("input")
  def swatch = override_row.find(:testid, "override-swatch")
end
