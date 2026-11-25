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

  # The sublabel of an entry: the group's summary, led by a color chip when it names a color. The derivation stream
  # re-renders it into the same element, so the first paint and every update share this one markup.
  class Summary < Components::Base
    def initialize(group:)
      @group = group
    end

    def view_template
      span(class: "mr-1.5 inline-block size-2.5 rounded-full border align-middle", style: @group.summary_style, aria_hidden: "true") if @group.summary_style
      plain @group.summary
    end
  end

  def initialize(group:)
    @group = group
  end

  def view_template
    return inline_brand if @group.key == "brand"

    render Chadcn::Sidebar::MenuItem.new do
      render Chadcn::Dialog.new(id: @group.panel_id, modal: false) do
        render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Sidebar::MenuButton.new(size: "lg", class: "group/menu-button", data: { testid: @group.panel_id })) { entry }
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
      span(id: @group.summary_id, class: SUBLABEL) { render Summary.new(group: @group) }
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
    when "advanced" then div(id: @group.controls_id) { render Components::Editor::AdvancedOverrides.new(group: @group) }
    else rows
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
    all_values_link
  end

  # Outside the stream target: a derivation (always an unsaved theme) must not erase it.
  def all_values_link
    return unless @group.values_path

    p(class: "pt-2 text-xs") do
      a(href: @group.values_path, class: "underline underline-offset-4", data: { testid: "all-values-link" }) { "See all values" }
    end
  end
end
