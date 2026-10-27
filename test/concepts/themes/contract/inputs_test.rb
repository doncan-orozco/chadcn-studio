require "test_helper"

class Themes::Contract::InputsTest < ActiveSupport::TestCase
  def validate(**inputs) = Themes::Contract::Inputs.new.call(inputs)

  test "a primary alone is enough" do
    assert_predicate validate(primary: "oklch(0.55 0.2 250)"), :success?
  end

  test "values from a form are coerced" do
    result = validate(primary: "oklch(0.55 0.2 250)", tint: "0.5", chart_offsets: %w[-40 -20 0 20 40])

    assert_predicate result, :success?
    assert_in_delta 0.5, result[:tint]
    assert_equal [ -40.0, -20.0, 0.0, 20.0, 40.0 ], result[:chart_offsets]
  end

  test "primary must be an oklch color in range" do
    [ "#336699", "oklch(1.2 0.2 250)", "oklch(0.5 0.9 250)", "oklch(0.5 0.2 400)", "red" ].each do |bad|
      assert_includes validate(primary: bad).errors.to_h.keys, :primary, bad
    end
    assert_includes validate.errors.to_h.keys, :primary
  end

  test "tint stays within 0..1" do
    assert_includes validate(primary: "oklch(0.5 0.2 250)", tint: 1.5).errors.to_h.keys, :tint
  end

  test "radius is a rem string" do
    assert_includes validate(primary: "oklch(0.5 0.2 250)", radius: "10px").errors.to_h.keys, :radius
    assert_predicate validate(primary: "oklch(0.5 0.2 250)", radius: "0.5rem"), :success?
  end

  test "exactly five chart offsets" do
    assert_includes validate(primary: "oklch(0.5 0.2 250)", chart_offsets: [ 0, 1 ]).errors.to_h.keys, :chart_offsets
  end

  test "overrides accept known variables with oklch values" do
    assert_predicate validate(primary: "oklch(0.5 0.2 250)", overrides: { "dark" => { "ring" => "oklch(0.7 0.1 10)" } }), :success?
  end

  test "overrides refuse unknown variables, modes and destructive" do
    [ { "dark" => { "nope" => "oklch(0.7 0.1 10)" } }, { "sepia" => {} }, { "light" => { "destructive" => "oklch(0.5 0.2 20)" } } ].each do |overrides|
      assert_includes validate(primary: "oklch(0.5 0.2 250)", overrides: overrides).errors.to_h.keys, :overrides, overrides.inspect
    end
  end

  test "overrides refuse values that could inject CSS" do
    overrides = { "light" => { "ring" => "red; } body { x: url(a)" } }

    assert_includes validate(primary: "oklch(0.5 0.2 250)", overrides: overrides).errors.to_h.keys, :overrides
  end

  test "primary must be opaque and readable by the gem" do
    [ "oklch(0.5 0.2 250 / 50%)", "oklch(-0 0.2 250)" ].each do |bad|
      assert_includes validate(primary: bad).errors.to_h.keys, :primary, bad
    end
    assert_predicate validate(primary: "OKLCH(0.55000 0.2 250)"), :success?
  end

  test "alpha is allowed only on dark border and input overrides" do
    alpha = "oklch(1 0 0 / 12%)"

    assert_predicate validate(primary: "oklch(0.5 0.2 250)", overrides: { "dark" => { "border" => alpha } }), :success?
    [ { "light" => { "border" => alpha } }, { "dark" => { "ring" => alpha } } ].each do |overrides|
      assert_includes validate(primary: "oklch(0.5 0.2 250)", overrides: overrides).errors.to_h.keys, :overrides, overrides.inspect
    end
  end

  test "chart offsets stay within one turn and finite" do
    [ [ 0, 0, 0, 0, 361 ], [ 0, 0, 0, 0, -361 ], %w[0 0 0 0 1e400] ].each do |offsets|
      assert_includes validate(primary: "oklch(0.5 0.2 250)", chart_offsets: offsets).errors.to_h.keys, :chart_offsets, offsets.inspect
    end
    assert_predicate validate(primary: "oklch(0.5 0.2 250)", chart_offsets: [ -360, 0, 0, 0, 360 ]), :success?
  end
end
