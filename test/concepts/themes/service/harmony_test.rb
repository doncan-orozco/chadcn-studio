require "test_helper"

class Themes::Service::HarmonyTest < ActiveSupport::TestCase
  include PaletteAssertions

  BLUE = { primary: "oklch(0.55 0.2 250)", tint: 0.5 }.freeze

  test "the worked example of derivation.md reproduces" do
    palette = Themes::Service::Harmony.call(BLUE)

    {
      root: { "background" => "oklch(1 0 0)", "foreground" => "oklch(0.141 0.008 250)", "primary" => "oklch(0.55 0.2 250)",
              "primary-foreground" => "oklch(0.985 0 0)", "secondary" => "oklch(0.967 0.008 250)",
              "muted-foreground" => "oklch(0.54 0.016 250)", "border" => "oklch(0.92 0.008 250)",
              "ring" => "oklch(0.705 0.12 250)", "chart-1" => "oklch(0.65 0.2 210)", "chart-5" => "oklch(0.65 0.2 290)",
              "sidebar-primary" => "oklch(0.55 0.2 250)", "destructive" => "oklch(0.577 0.245 27.325)", "radius" => "0.625rem" },
      dark: { "background" => "oklch(0.141 0.008 250)", "foreground" => "oklch(0.985 0.008 250)", "primary" => "oklch(0.7 0.16 250)",
              "primary-foreground" => "oklch(0.141 0.008 250)", "secondary" => "oklch(0.274 0.008 250)",
              "muted-foreground" => "oklch(0.705 0.015 250)", "border" => "oklch(1 0 0 / 10%)",
              "ring" => "oklch(0.552 0.12 250)", "chart-1" => "oklch(0.7 0.2 210)", "sidebar-primary" => "oklch(0.7 0.16 250)",
              "destructive" => "oklch(0.704 0.191 22.216)" }
    }.each do |side, expected|
      expected.each { |name, value| assert_equal value, palette.public_send(side)[name], "#{side} --#{name}" }
    end
  end

  test "the palette is complete and radius lives in root only" do
    palette = Themes::Service::Harmony.call(BLUE)

    assert_valid_palette palette
    assert_not palette.dark.key?("radius")
  end

  test "defaults derive a valid palette from the primary alone" do
    assert_valid_palette Themes::Service::Harmony.call(primary: "oklch(0.21 0.006 285.885)")
  end

  test "an override replaces exactly its variable and keeps the rest" do
    base = Themes::Service::Harmony.call(BLUE)
    palette = Themes::Service::Harmony.call(BLUE.merge(overrides: { "dark" => { "ring" => "oklch(0.8 0.1 10)" } }))

    assert_equal "oklch(0.8 0.1 10)", palette.dark["ring"]
    assert_equal base.root, palette.root
    assert_equal base.dark.except("ring"), palette.dark.except("ring")
  end

  test "an overridden foreground is not repaired" do
    low = "oklch(0.6 0 0)"
    palette = Themes::Service::Harmony.call(BLUE.merge(overrides: { "light" => { "foreground" => low } }))

    assert_equal low, palette.root["foreground"]
  end

  test "a hex light override does not raise" do
    palette = Themes::Service::Harmony.call(BLUE.merge(overrides: { "light" => { "background" => "#fafafa", "card" => "#ffffff" } }))

    assert_equal "#fafafa", palette.root["background"]
  end

  test "mid lightness primaries are repaired until the pair passes" do
    result = Themes::Service::Harmony.derive(primary: "oklch(0.55 0.1 150)")

    assert_valid_palette result.palette
    assert_operator result.repairs, :>, 0
    # Two builds, each repairing every pair in both modes, plus the primary shift.
    budget = 2 * Chadcn::Theme::CONTRAST_PAIRS.size * Themes::Service::Harmony::MODES.size * Themes::Service::Harmony::REPAIR_MAX_STEPS + 1

    assert_operator result.repairs, :<=, budget
  end

  test "a malformed primary raises" do
    assert_raises(Themes::Oklch::Invalid) { Themes::Service::Harmony.call(primary: "blue") }
  end

  test "radius and chart offsets are inputs" do
    palette = Themes::Service::Harmony.call(BLUE.merge(radius: "1rem", chart_offsets: [ 0, 10, 20, 30, 40 ]))

    assert_equal "1rem", palette.root["radius"]
    assert_equal "oklch(0.65 0.2 260)", palette.root["chart-2"]
  end

  test "string keys from a JSON column work too" do
    assert_equal Themes::Service::Harmony.call(BLUE), Themes::Service::Harmony.call(BLUE.stringify_keys)
  end

  test "override values are normalised to the canonical spelling" do
    palette = Themes::Service::Harmony.call(BLUE.merge(overrides: { "dark" => { "ring" => "OKLCH(0.80000 0.1 10)" } }))

    assert_equal "oklch(0.8 0.1 10)", palette.dark["ring"]
  end
end
