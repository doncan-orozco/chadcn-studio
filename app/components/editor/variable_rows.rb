# frozen_string_literal: true

# The variables of a group with their light and dark values, stacked so a long oklch() wraps inside the popover instead of
# running past it; replaced by the derivation stream.
class Components::Editor::VariableRows < Components::Base
  def initialize(rows:)
    @rows = rows
  end

  def view_template
    ul(class: "space-y-2 text-xs", data: { testid: "variable-rows" }) do
      @rows.each { |row| variable(row) }
    end
  end

  private

  def variable(row)
    li(class: "min-w-0 space-y-1") do
      span(class: "font-mono") { row.name }
      div(class: "grid min-w-0 gap-1 text-muted-foreground") do
        value("light", "Light #{row.name}", row.light, row.light_style)
        value("dark", "Dark #{row.name}", row.dark, row.dark_style)
      end
    end
  end

  def value(mode, label, text, style)
    span(class: "flex min-w-0 items-start gap-1") do
      swatch(style, label)
      span(class: "min-w-0 font-mono break-all select-all", data: { value: mode }, title: label) { text }
    end
  end

  def swatch(style, label)
    return span(class: "size-4") unless style

    span(class: "size-4 rounded-sm border", style: style, title: label, role: "img", aria: { label: label })
  end
end
