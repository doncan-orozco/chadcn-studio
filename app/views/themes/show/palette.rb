# frozen_string_literal: true

class Views::Themes::Show::Palette < Views::Base
  def initialize(rows)
    @rows = rows
  end

  def view_template
    render Chadcn::Table.new(data: { testid: "palette" }) do |table|
      table.caption { "Every variable of the theme, light and dark." }
      table.header do
        table.row do
          table.head { "Variable" }
          table.head { "Light" }
          table.head { "Dark" }
        end
      end
      table.body { @rows.each { |row| palette_row(table, row) } }
    end
  end

  private

  def palette_row(table, row)
    table.row do
      table.cell(class: "font-mono") { row.name }
      table.cell { value(row.light, row.light_style) }
      table.cell { value(row.dark, row.dark_style) }
    end
  end

  def value(text, style)
    div(class: "flex items-center gap-2") do
      span(class: "size-4 shrink-0 rounded-sm border", style: style, aria: { hidden: "true" }) if style
      span(class: "font-mono text-xs") { text }
    end
  end
end
