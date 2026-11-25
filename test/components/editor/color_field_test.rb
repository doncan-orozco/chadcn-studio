require "test_helper"

class Components::Editor::ColorFieldTest < ActiveSupport::TestCase
  setup { @page = Capybara.string(Components::Editor::ColorField.new(primary: "oklch(0.55 0.2 250)", hex: "#0f766e").call) }

  test "a Hex field beside the picker is prefilled with the color as hex and named for assistive tech" do
    assert_equal "#0f766e", @page.find_field("Hex").value
    assert @page.has_css?("[data-controller='editor--color'] input[type=color]#brand-color")
  end

  test "the Hex field is not submitted with the form, and reports a bad value in a described alert" do
    assert_nil @page.find_field("Hex")[:name]
    assert_equal "brand-hex-error", @page.find_field("Hex")["aria-describedby"]
    assert @page.has_css?("#brand-hex-error[role=alert][hidden]", visible: :all, text: "Use a hex color such as #0f766e.")
  end

  test "typing is wired to the color controller and Enter does not submit Save" do
    action = @page.find_field("Hex")["data-action"]

    assert_includes action, "change->editor--color#typeHex"
    assert_includes action, "keydown.enter->editor--color#typeHex:prevent"
  end
end
