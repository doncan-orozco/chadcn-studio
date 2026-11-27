require "test_helper"

class Components::Editor::VariableRowsTest < ActiveSupport::TestCase
  Row = Struct.new(:name, :light, :dark, :light_style, :dark_style, keyword_init: true)

  setup do
    row = Row.new(name: "--primary", light: "oklch(0.488 0.243 264.376)", dark: "oklch(0.62 0.2 264)", light_style: "background-color: oklch(0.488 0.243 264.376)", dark_style: nil)
    @html = Components::Editor::VariableRows.new(rows: [ row ]).call
  end

  test "names which value is Light and which is Dark on their own lines" do
    assert_match(/>Light<.*data-value="light"/m, @html)
    assert_match(/>Dark<.*data-value="dark"/m, @html)
  end

  test "keeps the full values as text" do
    assert_includes @html, ">oklch(0.488 0.243 264.376)</span>"
    assert_includes @html, ">oklch(0.62 0.2 264)</span>"
  end
end
