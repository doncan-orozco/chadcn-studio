# frozen_string_literal: true

class Views::Themes::Show::Palette < Views::Base
  def initialize(sections)
    @sections = sections
  end

  def view_template
    h2(id: "all-values", class: "mb-2 scroll-mt-6 text-lg font-semibold") { "All values" }
    div(data: { testid: "palette" }) { @sections.each { |section| variables_table(section) } }
  end

  private

  def variables_table(section)
    h3(class: "mt-4 mb-2 text-sm font-medium text-foreground/70") { section.heading }
    render Chadcn::Table.new(data: { testid: "palette-#{section.slug}" }) do |table|
      table.caption(class: "sr-only") { "#{section.heading} variables of the theme, light and dark." }
      table.header do
        table.row do
          table.head { "Variable" }
          table.head { "Light" }
          table.head { "Dark" }
        end
      end
      table.body { section.rows.each { |row| palette_row(table, row) } }
    end
  end

  def palette_row(table, row)
    table.row do
      table.cell do
        div(class: "font-medium") { row.label }
        div(class: "font-mono text-xs text-muted-foreground") { row.name }
      end
      table.cell { value(row.light, row.light_hex, row.light_style) }
      table.cell { value(row.dark, row.dark_hex, row.dark_style) }
    end
  end

  def value(text, hex, style)
    div(class: "flex items-center gap-2") do
      span(class: "size-4 shrink-0 rounded-sm border border-foreground/40", style: style, aria: { hidden: "true" }) if style
      div(class: "grid font-mono text-xs") do
        span(class: "text-foreground") { hex } if hex
        span(class: "text-muted-foreground") { text }
      end
    end
  end
end
