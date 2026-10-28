# frozen_string_literal: true

# The Turbo Stream of a successful derivation: the palette the preview root carries, the group summaries and variable
# lists, the advanced fields (derived values as placeholders) and, when asked, the brand controls at the new color.
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
    replace("brand-controls") { render Components::Editor::BrandControls.new(group: @editor.group("brand")) } if @controls
  end

  private

  def group_streams(group)
    replace(group.summary_id) { plain group.summary }
    replace(group.rows_id) { render Components::Editor::VariableRows.new(rows: group.rows) } unless group.variables.empty? || group.key == "advanced"
    replace("advanced-overrides") { render Components::Editor::AdvancedOverrides.new(group: group) } if group.key == "advanced"
  end

  # `update` keeps the target element, so ids and the controllers hosted on them stay put.
  def replace(target, &)
    turbo_stream(action: "update", target: target) { template(&) }
  end
end
