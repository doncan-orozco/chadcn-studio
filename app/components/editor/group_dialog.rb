# frozen_string_literal: true

# A sidebar entry that opens its group's inputs: a non-modal `Chadcn::Dialog` (a bottom sheet on small screens) whose
# content is force-mounted into the editor form, so a closed group keeps its fields and the stream can reach them.
class Components::Editor::GroupDialog < Components::Base
  CONTAINER = "#editor-panels"
  # The trigger button is the `group/menu-button`. Hovered, active or open (the selected group) it paints --sidebar-accent,
  # where muted text is under 4.5:1, so its sublabel takes the accent foreground; sibling entries stay muted.
  SUBLABEL = "truncate text-xs text-muted-foreground group-hover/menu-button:text-sidebar-accent-foreground " \
             "group-data-[active=true]/menu-button:text-sidebar-accent-foreground " \
             "group-data-[state=open]/menu-button:text-sidebar-accent-foreground"
  PANEL = "data-[state=closed]:hidden max-sm:top-auto max-sm:bottom-0 max-sm:left-0 max-sm:max-w-none max-sm:translate-x-0 max-sm:translate-y-0 " \
          "max-sm:rounded-b-none max-h-[85svh] overflow-y-auto sm:top-24 sm:right-4 sm:left-auto sm:max-w-sm sm:translate-x-0 sm:translate-y-0"

  def initialize(group:)
    @group = group
  end

  def view_template
    return inline_brand if @group.key == "brand"

    render Chadcn::Sidebar::MenuItem.new do
      render Chadcn::Dialog.new(id: @group.panel_id, modal: false) do
        render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Sidebar::MenuButton.new(id: @group.trigger_id, size: "lg", class: "group/menu-button", data: { testid: @group.panel_id })) { entry }
        render Chadcn::Dialog::Portal.new(force_mount: true, container: CONTAINER) { panel }
      end
    end
  end

  private

  # The brand color is the first thing a person changes, so it is never behind a click: its swatch and sliders sit open at
  # the top of the sidebar, under the same ids the streams update.
  def inline_brand
    section(class: "grid gap-3 border-b p-2", aria: { labelledby: "#{@group.panel_id}-heading" }, data: { testid: "#{@group.panel_id}-panel" }) do
      h2(id: "#{@group.panel_id}-heading", class: "text-sm font-medium") { @group.label }
      p(id: @group.summary_id, class: "truncate text-xs text-muted-foreground") { @group.summary }
      div(id: @group.controls_id) { render Components::Editor::BrandControls.new(group: @group) }
      details(class: "text-sm") do
        summary(class: "cursor-pointer text-muted-foreground") { "All brand variables" }
        rows
      end
    end
  end

  def entry
    span(class: "grid flex-1 text-left leading-tight") do
      span(class: "truncate font-medium") { @group.label }
      span(id: @group.summary_id, class: SUBLABEL) { @group.summary }
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
    when "surfaces" then surfaces
    when "radius" then radius
    when "dark" then render Components::Editor::ModeSwitch.new
    when "advanced" then advanced
    else rows
    end
  end

  # The filter sits outside the stream target, so a derivation never clears what was typed; the controller re-applies it to the
  # rows the stream brings in.
  def advanced
    div(data: { controller: "editor--variable-filter", editor__variable_filter_empty_label_value: Components::Editor::VariableFilter::EMPTY }) do
      render Components::Editor::VariableFilter.new
      div(id: @group.controls_id) { render Components::Editor::AdvancedOverrides.new(group: @group) }
    end
  end

  def surfaces
    render Components::Editor::SliderField.new(id: "neutral-tint", label: "Neutral tint", value: @group.tint, min: 0, max: 1, step: 0.05, live: false, name: "theme[inputs][tint]")
    rows
  end

  def radius
    render Components::Editor::SliderField.new(id: "radius", label: "Corner radius", value: @group.radius_rem, min: 0, max: 1.5, step: 0.05, channel: "radius", unit: "rem")
    rows
  end

  def rows
    div(id: @group.rows_id) { render Components::Editor::VariableRows.new(rows: @group.rows) }
    advanced_link if @group.pinnable?
    all_values_link
  end

  # The rows only show values; setting one exactly happens in Advanced. This closes the panel and opens that group's.
  def advanced_link
    p(class: "flex flex-wrap items-center gap-x-2 pt-2 text-xs text-muted-foreground", data: { controller: "editor--panel-link", editor__panel_link_trigger_id_value: ::Themes::Presenter::Group.trigger_id("advanced"), editor__panel_link_focus_id_value: Components::Editor::VariableFilter::ID }) do
      span { "To set one exactly, use Advanced" }
      render Chadcn::Dialog::Close.new(as_child: Chadcn::Button.new(variant: "outline", size: "sm", data: { action: "click->editor--panel-link#open", testid: "open-advanced" })) { "Open Advanced" }
    end
  end

  # Outside the stream target: a derivation (always an unsaved theme) must not erase it.
  def all_values_link
    return unless @group.values_path

    p(class: "pt-2 text-xs") do
      a(href: @group.values_path, class: "underline underline-offset-4", data: { testid: "all-values-link" }) { "See all values" }
    end
  end
end
