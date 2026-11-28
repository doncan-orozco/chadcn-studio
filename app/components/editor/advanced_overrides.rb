# frozen_string_literal: true

# Every variable of each mode with an override field. A filled field pins the variable and survives re-derivation;
# clearing it hands the variable back to the rule. The derived value is the placeholder.
class Components::Editor::AdvancedOverrides < Components::Base
  def initialize(group:)
    @group = group
    @override_sections = ::Themes::Presenter::OverrideSections.new(group)
  end

  def view_template
    div(class: "grid gap-4") do
      p(class: "text-sm text-muted-foreground", data: { testid: "overrides-note" }) do
        "Type a hex color to pin a variable; the text already in a field is the color the rule gives. Clear a field to follow the rule again. Closing this panel keeps your overrides; Save the theme to store them."
      end
      render Chadcn::Tabs.new(default_value: @group.modes.first) do |tabs|
        tabs.list(aria: { label: "Mode" }) do
          @group.modes.each { |mode| tabs.trigger(value: mode, data: { testid: "overrides-mode-#{mode}" }) { mode.capitalize } }
        end
        @group.modes.each { |mode| panel(tabs, mode) }
      end
    end
  end

  private

  # Both panels stay mounted so the hidden mode's fields still post with the form; each holds its own stream target.
  def panel(tabs, mode)
    tabs.content(value: mode, force_mount: true, class: "data-[state=inactive]:hidden") do
      div(id: @override_sections.panel_id(mode)) do
        render Components::Editor::OverrideFields.new(mode: mode, sections: @override_sections.sections(mode))
      end
    end
  end
end
