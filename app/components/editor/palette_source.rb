# frozen_string_literal: true

# Both palettes as data for the preview controller, which sets them on the preview root. Server-derived, never computed in JS.
class Components::Editor::PaletteSource < Components::Base
  def initialize(palette:)
    @palette = palette
  end

  def view_template
    div(hidden: true, data: { testid: "palette-source", editor__preview_target: "palette", light: @palette[:light].to_json, dark: @palette[:dark].to_json })
  end
end
