require "test_helper"

class Themes::Operation::DeriveTest < ActiveSupport::TestCase
  include PaletteAssertions

  test "derives a valid palette and persists nothing" do
    assert_no_difference [ -> { Theme.count }, -> { Generation.count } ] do
      payload = Themes::Operation::Derive.new.call(inputs: { "primary" => "oklch(0.55 0.2 250)", "tint" => 0.5 }).value!

      assert_valid_palette payload[:palette]
      assert_equal %i[inputs palette repairs warnings], payload.keys.sort
      assert_equal "oklch(0.55 0.2 250)", payload[:palette].root["primary"]
    end
  end

  test "contract errors fail with :invalid" do
    failure = Themes::Operation::Derive.new.call(inputs: { "primary" => "blue" }).failure

    assert_equal :invalid, failure[:code]
    assert_includes failure[:errors].keys, :primary
  end

  test "an override that breaks contrast fails with :contrast and the failing pairs" do
    inputs = { primary: "oklch(0.55 0.2 250)", overrides: { "light" => { "foreground" => "oklch(0.95 0 0)" } } }
    failure = Themes::Operation::Derive.new.call(inputs: inputs).failure

    assert_equal :contrast, failure[:code]
    assert_match(/--foreground on --background/, failure[:errors].join)
  end

  test "an alpha or upper-case override cannot dodge the strict gate" do
    [ { "light" => { "foreground" => "oklch(0.95 0 0 / 50%)" } }, { "light" => { "foreground" => "OKLCH(0.95 0 0)" } } ].each do |overrides|
      outcome = Themes::Operation::Derive.new.call(inputs: { primary: "oklch(0.55 0.2 250)", overrides: overrides })

      assert_predicate outcome, :failure?, overrides.inspect
      assert_includes %i[invalid contrast], outcome.failure[:code]
    end
  end

  test "a non-finite chart offset fails with :invalid" do
    failure = Themes::Operation::Derive.new.call(inputs: { primary: "oklch(0.55 0.2 250)", chart_offsets: %w[0 0 0 0 1e400] }).failure

    assert_equal :invalid, failure[:code]
    assert_includes failure[:errors].keys, :chart_offsets
  end

  test "negative zero never reaches the palette" do
    [ { primary: "oklch(0.55 0.2 250)", tint: "-0" }, { primary: "oklch(0.55 0.2 0)", chart_offsets: [ -360, 0, 0, 0, 0 ] } ].each do |inputs|
      palette = Themes::Operation::Derive.new.call(inputs: inputs).value![:palette]

      assert_valid_palette palette, inputs.inspect
      (palette.root.values + palette.dark.values).each { |value| refute_match(/(?<![\w.])-0(?![\d.])/, value, inputs.inspect) }
    end
  end
end
