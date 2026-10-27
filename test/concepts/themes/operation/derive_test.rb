require "test_helper"

class Themes::Operation::DeriveTest < ActiveSupport::TestCase
  include PaletteAssertions

  test "derives a valid palette and persists nothing" do
    assert_no_difference -> { Theme.count } do
      payload = Themes::Operation::Derive.new.call(inputs: { "primary" => "oklch(0.55 0.2 250)", "tint" => 0.5 }).value!

      assert_valid_palette payload[:palette]
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
end
