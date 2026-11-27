# frozen_string_literal: true

# The three sliders of the primary color (L, C, H): fine-tuning beside the hex.
class Components::Editor::BrandSliders < Components::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    render Components::Editor::SliderField.new(id: "primary-lightness", label: "Lightness", value: @group.lightness, min: 0, max: 1, step: 0.005, channel: "lightness", speak: { scale: 100, unit: "%" })
    render Components::Editor::SliderField.new(id: "primary-chroma", label: "Chroma", value: @group.chroma, min: 0, max: 0.4, step: 0.005, channel: "chroma", speak: { digits: 2 })
    render Components::Editor::SliderField.new(id: "primary-hue", label: "Hue", value: @group.hue, min: 0, max: 360, step: 1, channel: "hue", speak: { unit: "°" })
  end
end
