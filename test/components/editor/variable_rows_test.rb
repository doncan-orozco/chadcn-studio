require "test_helper"

class Components::Editor::VariableRowsTest < ActiveSupport::TestCase
  Row = Struct.new(:name, :light, :dark, :light_style, :dark_style, keyword_init: true)

  test "the light and dark values stack and wrap instead of being cut" do
    html = Components::Editor::VariableRows.new(rows: [ row ]).call

    assert_includes html, 'class="grid min-w-0 gap-1 text-muted-foreground"'
    assert_includes html, "oklch(0.985 0.006 286.032)"
    assert_includes html, "oklch(0.274 0.006 286.033)"
    assert_includes html, "break-all"
    assert_not_includes html, "truncate"
  end

  private

  def row
    Row.new(name: "--border", light: "oklch(0.985 0.006 286.032)", dark: "oklch(0.274 0.006 286.033)", light_style: nil, dark_style: nil)
  end
end
