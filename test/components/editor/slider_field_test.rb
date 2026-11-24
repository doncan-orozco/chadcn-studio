require "test_helper"

class Components::Editor::SliderFieldTest < ActiveSupport::TestCase
  SLIDER = { id: "radius", label: "Corner radius", value: 0.625, min: 0, max: 1.5, step: 0.05, channel: "radius" }.freeze

  test "a slider with a unit gets a number box and its value in the label" do
    html = render_field(unit: "rem")

    assert_includes html, "Corner radius <output"
    assert_includes html, ">0.625rem</output>"
    assert_includes html, 'type="number"'
    assert_includes html, 'step="0.05"'
    assert_includes html, "editor--slider-number#type"
    assert_includes html, "chadcn--slider:value-change->editor--slider-number#mirror"
  end

  test "a slider without a unit stays a plain slider" do
    html = render_field

    assert_not_includes html, "<output"
    assert_not_includes html, 'type="number"'
    assert_not_includes html, "editor--slider-number"
  end

  private

  def render_field(**options) = Components::Editor::SliderField.new(**SLIDER, **options).call
end
