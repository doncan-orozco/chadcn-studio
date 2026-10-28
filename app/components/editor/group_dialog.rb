# frozen_string_literal: true

# A sidebar entry that opens its group's inputs: a non-modal `Chadcn::Dialog` (a bottom sheet on small screens) whose
# content is force-mounted into the editor form, so a closed group keeps its fields and the stream can reach them.
class Components::Editor::GroupDialog < Components::Base
  CONTAINER = "#editor-panels"
  PANEL = "data-[state=closed]:hidden max-sm:top-auto max-sm:bottom-0 max-sm:left-0 max-sm:max-w-none max-sm:translate-x-0 max-sm:translate-y-0 " \
          "max-sm:rounded-b-none max-h-[85svh] overflow-y-auto sm:top-24 sm:right-4 sm:left-auto sm:max-w-sm sm:translate-x-0 sm:translate-y-0"

  def initialize(group:)
    @group = group
  end

  def view_template
    render Chadcn::Sidebar::MenuItem.new do
      render Chadcn::Dialog.new(id: @group.panel_id, modal: false, data: { editor_group: @group.key }) do
        render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Sidebar::MenuButton.new(size: "lg", data: { testid: @group.panel_id })) { entry }
        render Chadcn::Dialog::Portal.new(force_mount: true, container: CONTAINER) { panel }
      end
    end
  end

  private

  def entry
    span(class: "grid flex-1 text-left leading-tight") do
      span(class: "truncate font-medium") { @group.label }
      span(id: @group.summary_id, class: "truncate text-xs text-muted-foreground") { @group.summary }
    end
  end

  def panel
    render Chadcn::Dialog::Content.new(class: PANEL, data: { testid: "#{@group.panel_id}-panel" }) do
      render Chadcn::Dialog::Header.new do
        render(Chadcn::Dialog::Title.new { @group.label })
        render(Chadcn::Dialog::Description.new { @group.description })
      end
      body
    end
  end

  def body
    case @group.key
    when "brand" then brand
    when "surfaces" then surfaces
    when "radius" then radius
    when "dark" then render Components::Editor::ModeSwitch.new
    when "advanced" then div(id: "advanced-overrides") { render Components::Editor::AdvancedOverrides.new(group: @group) }
    else rows
    end
  end

  def brand
    div(id: "brand-controls") { render Components::Editor::BrandControls.new(group: @group) }
    rows
  end

  def surfaces
    render Components::Editor::SliderField.new(id: "neutral-tint", label: "Neutral tint", value: @group.tint, min: 0, max: 1, step: 0.05, live: false, name: "theme[inputs][tint]")
    rows
  end

  def radius
    render Components::Editor::SliderField.new(id: "radius", label: "Radius (rem)", value: @group.radius_rem, min: 0, max: 1.5, step: 0.025, channel: "radius")
    rows
  end

  def rows
    div(id: @group.rows_id) { render Components::Editor::VariableRows.new(rows: @group.rows) }
  end
end
