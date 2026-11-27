# frozen_string_literal: true

# Every variable of each mode with an override field. A filled field pins the variable and survives re-derivation;
# clearing it hands the variable back to the rule. The derived value is the placeholder.
class Components::Editor::AdvancedOverrides < Components::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    div(class: "grid gap-6") do
      p(class: "text-sm text-muted-foreground") { "Type a hex color such as #9ca3af, or an oklch(...) value. Clear a field to follow the rule again." }
      p(class: "text-sm text-muted-foreground", data: { testid: "overrides-close-note" }) { "Closing this panel keeps your overrides; they are shown as oklch once applied. Save the theme to store them." }
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
    div(class: "grid gap-1", data: { controller: "editor--override-swatch", testid: "override-row", overridden: override.overridden?.to_s, variable: override.name.delete_prefix("--"), editor__variable_filter_target: "row" }) do
      div(class: "flex items-center justify-between gap-2") do
        render Chadcn::Label.new(html_for: override.field_id, class: "text-xs") do
          plain "#{override.label} "
          span(class: "font-mono text-muted-foreground") { override.name }
        end
        render Chadcn::Badge.new(variant: "secondary", data: { testid: "overridden" }) { "Overridden" } if override.overridden?
      end
      div(class: "flex items-center gap-2") do
        swatch(override)
        render Chadcn::Input.new(
          id: override.field_id, name: override.field_name, default_value: override.value, placeholder: override.placeholder,
          autocomplete: "off", spellcheck: "false", class: "font-mono text-xs",
          data: { editor__override_swatch_target: "input", action: "input->editor--override-swatch#paint change->editor--preview#commit keydown.enter->editor--preview#confirm:prevent" }
        )
      end
    end
  end

  # The parsed color of the field: the typed value, else the derived one the rule would give. Decorative; the text beside it is the value.
  def swatch(override)
    span(class: "size-6 shrink-0 rounded-md border data-[state=invalid]:border-dashed data-[state=invalid]:border-destructive", style: override.style, aria: { hidden: "true" },
         data: { testid: "override-swatch", editor__override_swatch_target: "swatch", derived: override.style })
  end
end
