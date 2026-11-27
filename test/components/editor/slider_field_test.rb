require "test_helper"

class Components::Editor::SliderFieldTest < ActiveSupport::TestCase
  SLIDER = { id: "radius", label: "Corner radius", value: 0.625, min: 0, max: 1.5, step: 0.05, channel: "radius" }.freeze

  test "a slider with a unit gets a number box and its value in the label" do
    html = render_field(unit: "rem")

    assert_includes html, '<span id="radius-label">Corner radius</span>'
    assert_includes html, ">0.625rem</output>"
    assert_includes html, 'type="number"'
    assert_includes html, 'step="0.05"'
    assert_includes html, "editor--slider-number#type"
    assert_not_includes html, "slider-number#confirm"
    assert_includes html, 'form="radius-number-form"'
    assert_includes html, 'aria-label="Corner radius in rem"'
    assert_includes html, '<output for="radius-number"'
    assert_includes html, 'aria-live="off"'
    assert_includes html, 'data-editor--slider-number-target="slider"'
    assert_includes html, 'data-editor--slider-number-target="input"'
    assert_includes html, 'data-editor--slider-number-target="readout"'
    assert_includes html, 'data-editor--slider-number-unit-value="rem"'
    assert_includes html, "chadcn--slider:value-change->editor--slider-number#mirror"
  end

  test "a whole float prints like the browser does" do
    html = render_field(unit: "rem", value: 1.0)

    assert_includes html, ">1rem</output>"
    assert_includes html, 'value="1"'
  end

  test "a slider without a unit stays a plain slider" do
    html = render_field

    assert_not_includes html, "<output"
    assert_not_includes html, 'type="number"'
    assert_not_includes html, "editor--slider-number"
  end

  test "a slider with speak wires the controller that says its value" do
    html = render_field(speak: Components::Editor::SliderField::Speech.new(scale: 100, unit: "%"))

    assert_includes html, 'data-controller="editor--slider-speech"'
    assert_includes html, 'data-editor--slider-speech-scale-value="100"'
    assert_includes html, 'data-editor--slider-speech-unit-value="%"'
    assert_includes html, 'data-editor--slider-speech-target="slider"'
    assert_includes html, "chadcn--slider:value-change->editor--slider-speech#mirror"
    assert_includes html, 'aria-label="Corner radius"'
  end

  test "speak and unit cannot be combined" do
    assert_raises(ArgumentError) { render_field(unit: "rem", speak: Components::Editor::SliderField::Speech.new(digits: 1)) }
  end

  test "a misspelled speech option fails loudly" do
    assert_raises(ArgumentError) { Components::Editor::SliderField::Speech.new(digit: 1) }
  end

  test "a slider without speak wires nothing" do
    assert_not_includes render_field, "slider-speech"
  end

  private

  def render_field(**options) = Components::Editor::SliderField.new(**SLIDER, **options).call
end
