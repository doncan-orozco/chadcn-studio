# frozen_string_literal: true

# Every variable of each mode with an override field. A filled field pins the variable and survives re-derivation;
# clearing it hands the variable back to the rule. The derived value is the placeholder.
class Components::Editor::AdvancedOverrides < Components::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    div(class: "grid gap-6") do
      @group.modes.each { |mode| section_for(mode) }
    end
  end

  private

  def section_for(mode)
    section(class: "grid gap-3", aria: { labelledby: "overrides-#{mode}-heading" }) do
      h3(id: "overrides-#{mode}-heading", class: "text-sm font-semibold") { "#{mode.capitalize} mode" }
      @group.overrides(mode).each { |override| field(override) }
    end
  end

  def field(override)
    div(class: "grid gap-1", data: { testid: "override-row", overridden: override.overridden?.to_s }) do
      div(class: "flex items-center justify-between gap-2") do
        render Chadcn::Label.new(html_for: override.field_id, class: "font-mono text-xs") { override.name }
        render Chadcn::Badge.new(variant: "secondary", data: { testid: "overridden" }) { "Overridden" } if override.overridden?
      end
      render Chadcn::Input.new(
        id: override.field_id, name: override.field_name, default_value: override.value, placeholder: override.derived,
        autocomplete: "off", spellcheck: "false", class: "font-mono text-xs",
        data: { action: "change->editor--preview#commit keydown.enter->editor--preview#confirm:prevent" }
      )
    end
  end
end
