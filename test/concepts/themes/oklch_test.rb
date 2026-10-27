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

    assert_equal 10.0, color.alpha
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
    [ "#ffffff", "oklch(a b c)", "oklch(0.5 0.1)", "hsl(0 0% 0%)", "" ].each do |value|
      assert_raises(Themes::Oklch::Invalid, value) { Themes::Oklch.parse(value) }
    end
  end
end
