# frozen_string_literal: true

# One mode's override fields under the sidebar's group names; replaced by the derivation stream inside the mode's panel,
# so the tabs around it keep the mode the person is on.
class Components::Editor::OverrideFields < Components::Base
  def initialize(mode:, sections:)
    @mode = mode
    @sections = sections
  end

  def view_template
    div(class: "grid gap-4") do
      @sections.each do |fields_group|
        section(class: "grid gap-3", aria: { labelledby: heading_id(fields_group) }) do
          h3(id: heading_id(fields_group), class: "text-sm font-semibold") { fields_group.label }
          fields_group.overrides.each { |override| field(override) }
        end
      end
    end
  end

  private

  def heading_id(fields_group) = "overrides-#{@mode}-#{fields_group.key}-heading"

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
