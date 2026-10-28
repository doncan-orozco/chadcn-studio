# frozen_string_literal: true

# The variables of a group with their light and dark values; replaced by the derivation stream.
class Components::Editor::VariableRows < Components::Base
  def initialize(rows:)
    @rows = rows
  end

  def view_template
    ul(class: "space-y-1 text-xs", data: { testid: "variable-rows" }) do
      @rows.each do |row|
        li(class: "flex items-center justify-between gap-2") do
          span(class: "font-mono") { row.name }
          span(class: "flex items-center gap-1 text-muted-foreground") do
            swatch(row.light_style, "Light #{row.name}")
            swatch(row.dark_style, "Dark #{row.name}")
          end
        end
      end
    end
  end

  private

  def swatch(style, label)
    return span(class: "size-4") unless style

    span(class: "size-4 rounded-sm border", style: style, title: label, role: "img", aria: { label: label })
  end
end
