require "test_helper"

class Themes::Presenter::VariableTest < ActiveSupport::TestCase
  test "every variable has a label of its own, not its CSS name" do
    Chadcn::Theme::REQUIRED.each { |variable| assert_not_equal variable, Themes::Presenter::Variable.label(variable) }
  end

  test "a text variable is named for the surface it sits on" do
    assert_equal "Card text", Themes::Presenter::Variable.label("card-foreground")
    assert_equal "Chart color 3", Themes::Presenter::Variable.label("chart-3")
  end

  test "a value that is not a color has no hex" do
    assert_nil Themes::Presenter::Variable.hex("0.625rem")
    assert_nil Themes::Presenter::Variable.hex("oklch(1 0 0 / 10%)")
  end

  test "a row carries the label and the hex beside each oklch value" do
    row = Themes::Presenter::Variable.row("primary", light: "oklch(0.55 0.2 250)", dark: "oklch(0.7 0.16 250)")

    assert_equal [ "--primary", "Brand color" ], [ row.name, row.label ]
    assert_equal Themes::Oklch.parse("oklch(0.55 0.2 250)").to_hex, row.light_hex
    assert_equal "background-color: oklch(0.7 0.16 250)", row.dark_style
  end
end
