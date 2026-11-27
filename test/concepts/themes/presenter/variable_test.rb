require "test_helper"

class Themes::Presenter::VariableTest < ActiveSupport::TestCase
  test "every variable has a label of its own, not its CSS name" do
    Chadcn::Theme::REQUIRED.each { |variable| assert_not_equal variable, Themes::Presenter::Variable.label(variable) }
  end

  test "a text variable is named for the surface it sits on" do
    assert_equal "Card text", Themes::Presenter::Variable.label("card-foreground")
    assert_equal "Chart color 3", Themes::Presenter::Variable.label("chart-3")
    assert_equal "not-a-variable", Themes::Presenter::Variable.label("not-a-variable")
  end

  test "a value that is not a color has no hex" do
    assert_nil Themes::Presenter::Variable.hex("0.625rem")
    assert_nil Themes::Presenter::Variable.hex("oklch(1 0 0 / 10%)")
  end

  test "a row reads the wrapped theme and carries the label and the hex beside each oklch value" do
    theme = themes(:zinc)
    row = Themes::Presenter::Variable.new(theme).row("primary")

    assert_equal [ "--primary", "Brand color" ], [ row.name, row.label ]
    assert_equal Themes::Oklch.parse(theme.light["primary"]).to_hex, row.light_hex
    assert_equal Themes::Oklch.parse(theme.dark["primary"]).to_hex, row.dark_hex
    assert_equal "background-color: #{theme.dark['primary']}", row.dark_style
  end

  test "rows keep the order they are asked for" do
    assert_equal %w[--ring --primary], Themes::Presenter::Variable.new(themes(:zinc)).rows(%w[ring primary]).map(&:name)
  end
end
