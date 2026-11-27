require "test_helper"

class Components::Editor::VariableRowsTest < ActiveSupport::TestCase
  Row = Struct.new(:name, :label, :light, :dark, :light_style, :dark_style, :light_hex, :dark_hex, keyword_init: true)

  LIGHT = "oklch(0.488 0.243 264.376)"
  DARK = "oklch(0.62 0.2 264)"

  setup do
    @page = render_rows(row)
  end

  test "names which value is Light and which is Dark on the same line as the value" do
    item = @page.find("li")

    { "light" => "Light", "dark" => "Dark" }.each do |mode, label|
      line = item.find("[data-value=#{mode}]").find(:xpath, "ancestor::span[contains(@class, 'flex')][1]")

      assert line.text.start_with?(label), "expected the #{mode} line to start with #{label}, got #{line.text.inspect}"
    end
  end

  test "keeps the full values as text" do
    assert_equal LIGHT, @page.find("[data-value=light]").text
    assert_equal DARK, @page.find("[data-value=dark]").text
  end

  test "renders a swatch only for the mode that has a style" do
    page = render_rows(row(dark_style: nil))

    assert page.has_selector?("[role=img][aria-label='Light --primary']", count: 1)
    assert page.has_no_selector?("[role=img][aria-label='Dark --primary']")
  end

  test "names the variable in words with the CSS name beside it" do
    heading = @page.find("li > div", match: :first)

    assert_equal %w[Brand\ color --primary], heading.all("span").map(&:text)
  end

  test "shows the hex beside each oklch value, outside the value itself" do
    assert_includes @page.find("li").text, "#1d4ed8"
    assert_includes @page.find("li").text, "#60a5fa"
    assert_equal LIGHT, @page.find("[data-value=light]").text
  end

  test "shows no hex line for a value without one" do
    page = render_rows(row(light_hex: nil, dark_hex: nil))

    assert page.has_no_text?("#1d4ed8")
  end

  private

  def row(**overrides)
    Row.new(name: "--primary", label: "Brand color", light: LIGHT, dark: DARK, light_style: "background-color: #{LIGHT}", dark_style: "background-color: #{DARK}",
            light_hex: "#1d4ed8", dark_hex: "#60a5fa", **overrides)
  end

  def render_rows(*rows)
    Capybara.string(Components::Editor::VariableRows.new(rows: rows).call)
  end
end
