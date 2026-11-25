require "test_helper"

class Components::Editor::BrandSwatchTest < ActiveSupport::TestCase
  Group = Struct.new(:hex, :hex_swatch_style, keyword_init: true)

  test "shows the swatch in the hex and the hex as text, hiding the swatch from assistive tech" do
    html = Components::Editor::BrandSwatch.new(group: Group.new(hex: "#1d4ed8", hex_swatch_style: "background-color: #1d4ed8")).call

    assert_includes html, "background-color: #1d4ed8"
    assert_includes html, 'aria-hidden="true"'
    assert_includes html, ">#1d4ed8</span>"
  end
end
