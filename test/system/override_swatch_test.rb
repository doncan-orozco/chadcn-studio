require "application_system_test_case"

class OverrideSwatchTest < ApplicationSystemTestCase
  setup do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "group-advanced").click
  end

  test "the swatch follows what is typed, before the field is committed, and falls back to the derived color" do
    row = find(:testid, "override-row", match: :first)
    swatch = row.find(:testid, "override-swatch")
    derived = swatch[:style]
    field = row.find("input")

    field.send_keys("#ff0000")

    assert_equal "typed", swatch["data-state"]
    assert_match(/\A(rgb\(255, 0, 0\)|color\(srgb 1 0 0\))\z/, swatch.style("background-color")["background-color"])

    field.send_keys(:backspace)

    assert_equal "invalid", swatch["data-state"]
    assert_equal derived, swatch[:style], "a half-typed hex shows the derived color, not a stale one"

    field.send_keys(*Array.new(6, :backspace))

    assert_equal derived, swatch[:style]
  end

  test "the panel says that closing keeps what was typed, and it does" do
    assert_text "Closing this panel keeps what you typed"
    field = find_field("override-light-border")
    field.send_keys("#9ca3af")
    find(:testid, "group-advanced-panel").send_keys(:escape)
    find(:testid, "group-advanced").click

    # As typed, or already restated in oklch once the committed derivation came back; either way it is kept.
    assert_includes [ "#9ca3af", "oklch(0.714 0.019 261.325)" ], find_field("override-light-border").value
  end
end
