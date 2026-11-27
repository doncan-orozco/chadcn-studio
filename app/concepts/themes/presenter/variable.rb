# frozen_string_literal: true

# One theme variable in the words of someone tuning it: what it colors, and its value as the hex they would type. Shared by the editor
# groups and the theme page so both say the same thing; the values themselves come from the theme (theme-science R1).
class Themes::Presenter::Variable
  # What each variable colors; the CSS name stays beside it for people who export.
  LABELS = {
    "background" => "Page background", "foreground" => "Page text", "primary" => "Brand color", "primary-foreground" => "Text on brand color",
    "destructive" => "Destructive color", "border" => "Borders", "input" => "Input borders", "ring" => "Focus ring", "sidebar-border" => "Sidebar borders", "sidebar-ring" => "Sidebar focus ring", "radius" => "Corner radius"
  }.freeze
  # Variables that come as a surface and its text: "card" is the background, "card-foreground" the text on it.
  SURFACE_NAMES = { "card" => "Card", "popover" => "Popover", "secondary" => "Secondary", "muted" => "Muted", "accent" => "Accent", "sidebar" => "Sidebar",
                    "sidebar-primary" => "Sidebar brand", "sidebar-accent" => "Sidebar accent" }.freeze

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

  def self.row(variable, light:, dark:)
    Row.new(name: "--#{variable}", label: label(variable), light: light, light_style: Themes::Presenter::Card.swatch_style(light), light_hex: hex(light),
            dark: dark, dark_style: Themes::Presenter::Card.swatch_style(dark), dark_hex: hex(dark))
  end
end
