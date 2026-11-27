require "test_helper"

class Components::Editor::VariableRowsTest < ActiveSupport::TestCase
  Row = Struct.new(:name, :light, :dark, :light_style, :dark_style, keyword_init: true)

  LIGHT = "oklch(0.488 0.243 264.376)"
  DARK = "oklch(0.62 0.2 264)"

  setup do
    @page = render_rows(Row.new(name: "--primary", light: LIGHT, dark: DARK, light_style: "background-color: #{LIGHT}", dark_style: "background-color: #{DARK}"))
  end

  test "names which value is Light and which is Dark on the same line as the value" do
    item = @page.find("li")

    { "light" => [ "Light", LIGHT ], "dark" => [ "Dark", DARK ] }.each do |mode, (label, value)|
      line = item.find("[data-value=#{mode}]").find(:xpath, "..")

      assert line.text.start_with?(label), "expected the #{mode} line to start with #{label}, got #{line.text.inspect}"
      assert_equal value, line.find("[data-value]").text
    end
  end

  test "keeps the full values as text" do
    assert_equal LIGHT, @page.find("[data-value=light]").text
    assert_equal DARK, @page.find("[data-value=dark]").text
  end

  test "renders a swatch only for the mode that has a style" do
    page = render_rows(Row.new(name: "--primary", light: LIGHT, dark: DARK, light_style: "background-color: #{LIGHT}", dark_style: nil))

    assert_selector_count page, "[role=img][aria-label='Light --primary']", 1
    assert_selector_count page, "[role=img][aria-label='Dark --primary']", 0
  end

  private

  def render_rows(*rows)
    Capybara.string(Components::Editor::VariableRows.new(rows: rows).call)
  end

  def assert_selector_count(page, selector, count)
    assert_equal count, page.all(selector).size
  end
end
