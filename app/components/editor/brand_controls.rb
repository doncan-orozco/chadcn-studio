# frozen_string_literal: true

# The brand group's inputs in two stream targets: the color field (picker and Hex) and the three sliders (L, C, H). A
# derivation redraws the one the person did not touch, so focus never drops and the Hex field always shows the current color.
class Components::Editor::BrandControls < Components::Base
  FIELD_ID = "brand-color-field"
  SLIDERS_ID = "brand-sliders"

  def initialize(group:)
    @group = group
  end

  def view_template
    div(class: "grid gap-4") do
      div(id: FIELD_ID) { render Components::Editor::ColorField.new(primary: @group.primary, hex: @group.hex) }
      div(id: SLIDERS_ID, class: "grid gap-4") { render Components::Editor::BrandSliders.new(group: @group) }
    end
  end
end
