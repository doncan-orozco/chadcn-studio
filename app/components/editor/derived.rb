# frozen_string_literal: true

# The Turbo Stream of a successful derivation: the palette the preview root carries, the group summaries and variable
# lists, the advanced fields (derived values as placeholders) and the half of the brand controls the person did not touch.
class Components::Editor::Derived < Components::Base
  register_element :turbo_stream

  def initialize(editor, controls: false)
    @editor = editor
    @controls = controls
  end

  def view_template
    replace("editor-errors") { plain "" }
    replace("editor-palette") { render Components::Editor::PaletteSource.new(palette: @editor.palette_json) }
    @editor.groups.each { |group| group_streams(group) }
    brand_streams(@editor.group("brand"))
  end

  private

  # A picked or typed color (`controls`) redraws the sliders at it; anything else (a slider, an override) redraws the picker
  # and the Hex field at the derived hex. The control the person is using is never replaced, so it keeps focus.
  def brand_streams(brand)
    replace(brand.swatch_id) { render Components::Editor::BrandSwatch.new(group: brand) }
    if @controls
      replace(Components::Editor::BrandControls::SLIDERS_ID) { render Components::Editor::BrandSliders.new(group: brand) }
    else
      replace(Components::Editor::BrandControls::FIELD_ID) { render Components::Editor::ColorField.new(primary: brand.primary, hex: brand.hex) }
    end
  end

  def group_streams(group)
    replace(group.summary_id) { plain group.summary }
    replace(group.rows_id) { render Components::Editor::VariableRows.new(rows: group.rows) } unless group.variables.empty? || group.key == "advanced"
    advanced_streams(group) if group.key == "advanced"
  end

  # Only the fields inside each mode's panel are swapped: the Tabs root and its selected mode stay put.
  def advanced_streams(group)
    sections = ::Themes::Presenter::OverrideSections.new(group)
    group.modes.each do |mode|
      replace(sections.panel_id(mode)) { render Components::Editor::OverrideFields.new(mode: mode, sections: sections.sections(mode)) }
    end
  end

  # `update` keeps the target element, so ids and the controllers hosted on them stay put.
  def replace(target, &)
    turbo_stream(action: "update", target: target) { template(&) }
  end
end
