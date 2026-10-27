require "test_helper"

class PaletteValidatorTest < ActiveSupport::TestCase
  test "passes a complete palette" do
    assert_predicate themes(:blue), :valid?
  end

  test "reports a missing radius" do
    theme = themes(:zinc)
    theme.light = theme.light.except("radius")

    assert_not theme.valid?
    assert_includes theme.errors[:base], "light (:root): missing --radius"
  end

  test "reports a missing dark variable" do
    theme = themes(:zinc)
    theme.dark = theme.dark.except("primary")

    assert_not theme.valid?
    assert(theme.errors[:base].any? { |message| message.include?("missing primary") })
  end

  test "reports a bare HSL triplet" do
    theme = themes(:zinc)
    theme.light = theme.light.merge("border" => "240 5.9% 90%")

    assert_not theme.valid?
    assert(theme.errors[:base].any? { |message| message.include?("bare HSL triplet") })
  end

  test "rejects palettes that are not hashes without raising" do
    theme = Theme.new(name: "Broken", slug: "broken", light: nil, dark: [], inputs: {})

    assert_not theme.valid?
    assert_includes theme.errors[:base], "palette must have light and dark variables"
  end
end
