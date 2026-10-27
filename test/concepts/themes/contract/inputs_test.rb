require "test_helper"

class Themes::Contract::InputsTest < ActiveSupport::TestCase
  def call(**inputs) = Themes::Contract::Inputs.new.call(inputs)

  test "a primary alone is enough" do
    assert_predicate call(primary: "oklch(0.55 0.2 250)"), :success?
  end

  test "values from a form are coerced" do
    result = call(primary: "oklch(0.55 0.2 250)", tint: "0.5", chart_offsets: %w[-40 -20 0 20 40])

    assert_predicate result, :success?
    assert_in_delta 0.5, result[:tint]
  end

  test "primary must be an oklch color in range" do
    [ "#336699", "oklch(1.2 0.2 250)", "oklch(0.5 0.9 250)", "oklch(0.5 0.2 400)", "red" ].each do |bad|
      assert_includes call(primary: bad).errors.to_h.keys, :primary, bad
    end
    assert_includes call.errors.to_h.keys, :primary
  end

  test "tint stays within 0..1" do
    assert_includes call(primary: "oklch(0.5 0.2 250)", tint: 1.5).errors.to_h.keys, :tint
  end

  test "radius is a rem string" do
    assert_includes call(primary: "oklch(0.5 0.2 250)", radius: "10px").errors.to_h.keys, :radius
    assert_predicate call(primary: "oklch(0.5 0.2 250)", radius: "0.5rem"), :success?
  end

  test "exactly five chart offsets" do
    assert_includes call(primary: "oklch(0.5 0.2 250)", chart_offsets: [ 0, 1 ]).errors.to_h.keys, :chart_offsets
  end

  test "overrides accept known variables with oklch values" do
    assert_predicate call(primary: "oklch(0.5 0.2 250)", overrides: { "dark" => { "ring" => "oklch(0.7 0.1 10)" } }), :success?
  end

  test "overrides refuse unknown variables, modes, destructive and unsafe values" do
    [ { "dark" => { "nope" => "oklch(0.7 0.1 10)" } }, { "sepia" => {} }, { "light" => { "destructive" => "oklch(0.5 0.2 20)" } },
      { "light" => { "ring" => "red; } body { x: url(a)" } } ].each do |overrides|
      assert_includes call(primary: "oklch(0.5 0.2 250)", overrides: overrides).errors.to_h.keys, :overrides, overrides.inspect
    end
  end
end
