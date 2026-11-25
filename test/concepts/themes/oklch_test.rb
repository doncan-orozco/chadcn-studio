require "test_helper"

class Themes::OklchTest < ActiveSupport::TestCase
  ZINC_VALUES = File.read(Rails.root.join("app/assets/tailwind/theme/theme.css")).scan(/oklch\([^)]*\)/).uniq.freeze

  test "the zinc preset has values to round-trip" do
    assert_operator ZINC_VALUES.size, :>, 10
  end

  test "round-trips every value of the zinc preset through parse and to_s" do
    ZINC_VALUES.each do |value|
      assert_equal value, Themes::Oklch.parse(value).to_s
    end
  end

  test "to_s prints at most three decimals and trims zeros" do
    assert_equal "oklch(0.5 0.123 285.886)", Themes::Oklch.new(0.5, 0.1234, 285.8857).to_s
    assert_equal "oklch(1 0 0)", Themes::Oklch.new(1, 0, 0).to_s
  end

  test "keeps the alpha of the dark border" do
    color = Themes::Oklch.parse("oklch(1 0 0 / 10%)")

    assert_in_delta(10.0, color.alpha)
    assert_equal "oklch(1 0 0 / 10%)", color.to_s
  end

  test "lighten and with_chroma return new colors" do
    color = Themes::Oklch.new(0.5, 0.1, 250)

    assert_equal "oklch(0.6 0.1 250)", color.lighten(0.1).to_s
    assert_equal "oklch(1 0.1 250)", color.lighten(0.9).lighten(0.5).to_s
    assert_equal "oklch(0.5 0.2 250)", color.with_chroma(0.2).to_s
    assert_equal "oklch(0.5 0.1 250)", color.to_s
  end

  test "colors with equal values are equal" do
    assert_equal Themes::Oklch.parse("oklch(0.5 0.1 250)"), Themes::Oklch.new(0.5, 0.1, 250)
  end

  test "rejects out-of-range input" do
    [ [ 1.1, 0, 0 ], [ -0.1, 0, 0 ], [ 0.5, 0.5, 0 ], [ 0.5, 0.1, 361 ], [ 0.5, 0.1, 10, 101 ] ].each do |args|
      assert_raises(Themes::Oklch::Invalid, args.inspect) { Themes::Oklch.new(*args) }
    end
  end

  test "rejects non-numeric input and malformed strings" do
    assert_raises(Themes::Oklch::Invalid) { Themes::Oklch.new("light", 0, 0) }
    assert_raises(Themes::Oklch::Invalid) { Themes::Oklch.new(nil, 0, 0) }
    assert_raises(Themes::Oklch::Invalid) { Themes::Oklch.new("0x1A", 0, 0) }
    [ "oklch(a b c)", "oklch(0.5 0.1)", "hsl(0 0% 0%)", "" ].each do |value|
      assert_raises(Themes::Oklch::Invalid, value) { Themes::Oklch.parse(value) }
    end
  end

  test "parses a six-digit hex color, with or without the hash, in any case" do
    [ "#1d4ed8", "1d4ed8", "#1D4ED8", " #1d4ed8 " ].each do |value|
      assert_equal "oklch(0.488 0.217 264.376)", Themes::Oklch.parse(value).to_s, value
    end
    assert_equal "oklch(0.714 0.019 261.325)", Themes::Oklch.parse("#9ca3af").to_s
    assert_equal "oklch(0.628 0.258 29.234)", Themes::Oklch.parse("#ff0000").to_s
  end

  test "parses a three-digit hex color as its doubled digits" do
    assert_equal Themes::Oklch.parse("#1144dd"), Themes::Oklch.parse("#14d")
    assert_equal "oklch(0.473 0.236 264.226)", Themes::Oklch.parse("#14D").to_s
  end

  test "a hex gray has no chroma and no hue" do
    assert_equal "oklch(1 0 0)", Themes::Oklch.parse("#fff").to_s
    assert_equal "oklch(0 0 0)", Themes::Oklch.parse("#000000").to_s
    assert_equal "oklch(0.6 0 0)", Themes::Oklch.parse("#808080").to_s
  end

  test "a hex color is opaque" do
    assert_nil Themes::Oklch.parse("#1d4ed8").alpha
  end

  test "rejects malformed hex" do
    [ "#", "#12", "#1234", "#12345", "#1234567", "#1d4ed8ff", "14d", "#ggg", "#1d4edg", "1d4ed", "# 1d4ed8", "#1d4ed8; x" ].each do |value|
      assert_raises(Themes::Oklch::Invalid, value) { Themes::Oklch.parse(value) }
    end
  end

  test "normalize_hex spells any hex as lower-case #rrggbb and refuses the rest" do
    assert_equal "#1d4ed8", Themes::Oklch.normalize_hex("#1D4ED8")
    assert_equal "#1d4ed8", Themes::Oklch.normalize_hex(" 1d4ed8 ")
    assert_equal "#11ddee", Themes::Oklch.normalize_hex("#1de")
    assert_nil Themes::Oklch.normalize_hex("oklch(0.5 0.1 250)")
  end

  test "to_hex writes the sRGB hex of a color, and a typed hex comes back within a few steps through the stored spelling" do
    assert_equal "#1d4ed8", Themes::Oklch.parse("#1d4ed8").to_hex
    assert_equal "#ffffff", Themes::Oklch.new(1, 0, 0).to_hex
    assert_equal "#000000", Themes::Oklch.new(0, 0, 0).to_hex
    stored = Themes::Oklch.parse(Themes::Oklch.parse("#1d4ed8").to_s)

    assert_equal "#1d4ed8", stored.to_hex
  end
end
