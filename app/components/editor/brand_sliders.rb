# frozen_string_literal: true

# The three sliders of the primary color (L, C, H): fine-tuning beside the hex.
class Components::Editor::BrandSliders < Components::Base
  Speech = Components::Editor::SliderField::Speech
  LIGHTNESS = Speech.new(scale: 100, digits: 1, unit: "%")
  CHROMA = Speech.new(digits: 3)
  HUE = Speech.new(unit: "°")

  def initialize(group:)
    @group = group
  end

  def view_template
    render Components::Editor::SliderField.new(id: "primary-lightness", label: "Lightness", value: @group.lightness, min: 0, max: 1, step: 0.005, channel: "lightness", speak: LIGHTNESS)
    render Components::Editor::SliderField.new(id: "primary-chroma", label: "Chroma", value: @group.chroma, min: 0, max: 0.4, step: 0.005, channel: "chroma", speak: CHROMA)
    render Components::Editor::SliderField.new(id: "primary-hue", label: "Hue", value: @group.hue, min: 0, max: 360, step: 1, channel: "hue", speak: HUE)
  end
end
