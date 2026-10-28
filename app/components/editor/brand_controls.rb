# frozen_string_literal: true

# The brand group's inputs: the native color picker and the three sliders of the primary color (L, C, H).
class Components::Editor::BrandControls < Components::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    div(class: "grid gap-4") do
      render Components::Editor::ColorField.new(primary: @group.primary)
      render Components::Editor::SliderField.new(id: "primary-lightness", label: "Lightness", value: @group.lightness, min: 0, max: 1, step: 0.005, channel: "lightness")
      render Components::Editor::SliderField.new(id: "primary-chroma", label: "Chroma", value: @group.chroma, min: 0, max: 0.4, step: 0.005, channel: "chroma")
      render Components::Editor::SliderField.new(id: "primary-hue", label: "Hue", value: @group.hue, min: 0, max: 360, step: 1, channel: "hue")
    end
  end
end
