# frozen_string_literal: true

# One theme variable in the words of someone tuning it: what it colors, and its value as the hex they would type. Shared by the editor
# groups and the theme page so both say the same thing; the values themselves come from the wrapped theme (theme-science R1).
# `label` and `hex` stay class methods for callers with a value but no theme (the Advanced override placeholder).
class Themes::Presenter::Variable < Core::Presenter::Base
  # What each variable colors; the CSS name stays beside it for people who export.
  LABELS = {
    "background" => "Page background", "foreground" => "Page text", "primary" => "Brand color", "primary-foreground" => "Text on brand color",
    "destructive" => "Destructive color", "border" => "Borders", "input" => "Input borders", "ring" => "Focus ring", "sidebar-border" => "Sidebar borders", "sidebar-ring" => "Sidebar focus ring", "radius" => "Corner radius"
  }.freeze
  # Variables that come as a surface and its text: "card" is the background, "card-foreground" the text on it.
  SURFACE_NAMES = { "card" => "Card", "popover" => "Popover", "secondary" => "Secondary", "muted" => "Muted", "accent" => "Accent", "sidebar" => "Sidebar",
                    "sidebar-primary" => "Sidebar brand", "sidebar-accent" => "Sidebar accent" }.freeze

  private_constant :LABELS, :SURFACE_NAMES

  Row = Data.define(:name, :label, :light, :light_style, :light_hex, :dark, :dark_style, :dark_hex)

  # "Card text" for card-foreground, "Chart color 3" for chart-3; the CSS name when nothing better is known.
  def self.label(variable)
    LABELS.fetch(variable) do
      stem = variable.delete_suffix("-foreground")
      chart_number = variable[/\Achart-(\d)\z/, 1]
      next "Chart color #{chart_number}" if chart_number

      surface = SURFACE_NAMES[stem]
      next variable unless surface

      "#{surface} #{stem == variable ? 'background' : 'text'}"
    end
  end

  # The hex a person would type for an oklch value; nil when hex cannot say it (translucent, or not a color such as a radius).
  def self.hex(value)
    color = Themes::Oklch.parse(value)
    color.alpha ? nil : color.to_hex
  rescue Themes::Oklch::Invalid
    nil
  end

  # One row per variable, in the order given.
  def rows(variables) = variables.map { |variable| row(variable) }

  def row(variable)
    Row.new(name: "--#{variable}", label: self.class.label(variable), light: light[variable], light_style: swatch(light[variable]), light_hex: self.class.hex(light[variable]),
            dark: dark[variable], dark_style: swatch(dark[variable]), dark_hex: self.class.hex(dark[variable]))
  end

  private

  def swatch(value) = Themes::Presenter::Card.swatch_style(value)
end
