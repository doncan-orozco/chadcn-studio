# frozen_string_literal: true

# One group of the editor sidebar (Brand color, Backgrounds, cards and text...): its label, summary and the variables it covers.
# The partition comes from the gem's variable set (theme-science R1); nothing here derives or validates a color.
class Themes::Presenter::Group < Core::Presenter::Base
  COLORS = Chadcn::Theme::REQUIRED
  BRAND = %w[primary primary-foreground ring].freeze
  CHARTS = COLORS.grep(/\Achart-/).freeze
  SIDEBAR = COLORS.grep(/\Asidebar/).freeze
  SURFACES = (COLORS - BRAND - CHARTS - SIDEBAR).freeze
  RADIUS = Chadcn::Theme::ROOT_ONLY
  MODES = %w[light dark].freeze
  # The variables a person reaches for most when pinning one, listed first in Advanced.
  PINNED_FIRST = %w[primary border ring].freeze
  PINNABLE = %w[surfaces charts sidebar].freeze

  DEFINITIONS = {
    "brand" => { label: "Brand color", description: "Pick the primary color; the rest of the palette follows.", variables: BRAND },
    "surfaces" => { label: "Backgrounds, cards and text", description: "Page and card backgrounds, borders and the text on them.", variables: SURFACES },
    "radius" => { label: "Radius", description: "How round corners are.", variables: RADIUS },
    "charts" => { label: "Charts", description: "The five chart colors.", variables: CHARTS },
    "sidebar" => { label: "Sidebar", description: "The sidebar mirror of the palette.", variables: SIDEBAR },
    "advanced" => { label: "Advanced", description: "Pin a single variable; the others keep following the rule.", variables: PINNED_FIRST + (COLORS - PINNED_FIRST) + RADIUS }
  }.freeze
  KEYS = DEFINITIONS.keys.freeze

  # What a collapsed group says, in the user's words: the brand color is named from the primary, the rest say what they change.
  SUMMARIES = { "surfaces" => "Page, card and border colors", "charts" => "Five chart colors", "sidebar" => "Sidebar colors" }.freeze
  # Upper bound of each hue name on the oklch wheel; pink also owns the wrap-around above the last bound.
  HUE_NAMES = [ [ 15, "pink" ], [ 40, "red" ], [ 75, "orange" ], [ 115, "yellow" ], [ 170, "green" ], [ 210, "teal" ], [ 275, "blue" ], [ 335, "purple" ] ].freeze
  # What each variable colors, in the words of someone tuning a theme; the CSS name stays beside it for people who export.
  VARIABLE_LABELS = {
    "background" => "Page background", "foreground" => "Page text", "primary" => "Brand color", "primary-foreground" => "Text on brand color",
    "border" => "Borders", "input" => "Input borders", "ring" => "Focus ring", "sidebar-border" => "Sidebar borders", "sidebar-ring" => "Sidebar focus ring", "radius" => "Corner radius"
  }.freeze
  # Variables that come as a surface and its text: "card" is the background, "card-foreground" the text on it.
  SURFACE_NAMES = { "card" => "Card", "popover" => "Popover", "secondary" => "Secondary", "muted" => "Muted", "accent" => "Accent", "sidebar" => "Sidebar",
                    "sidebar-primary" => "Sidebar brand", "sidebar-accent" => "Sidebar accent" }.freeze
  GRAY_CHROMA = 0.03
  DARK_LIGHTNESS = 0.4
  LIGHT_LIGHTNESS = 0.8
  BLACK_LIGHTNESS = 0.3
  WHITE_LIGHTNESS = 0.9

  Row = Data.define(:name, :light, :light_style, :dark, :dark_style)
  Override = Data.define(:mode, :name, :label, :derived, :value, :style, :field_name, :field_id) do
    def overridden? = value.present?

    # The derived value in the hex a person would type; the oklch string when hex cannot say it (translucent, or not a color).
    def placeholder
      color = Themes::Oklch.parse(derived)
      color.alpha ? derived : color.to_hex
    rescue Themes::Oklch::Invalid
      derived
    end
  end

  # The sidebar entry that opens a group's panel; links between panels name it.
  def self.trigger_id(key) = "group-#{key}-trigger"

  def self.all(theme) = KEYS.map { |key| new(theme, key: key) }

  def initialize(theme, key:)
    raise ArgumentError, "unknown group #{key.inspect}" unless DEFINITIONS.key?(key)

    super(theme)
    @key = key
  end

  attr_reader :key

  def label = definition[:label]
  def description = definition[:description]
  def summary_id = "summary-#{key}"
  def rows_id = "rows-#{key}"
  def panel_id = "group-#{key}"
  def trigger_id = self.class.trigger_id(key)
  def advanced_trigger_id = self.class.trigger_id("advanced")

  # The element the derivation stream updates with the brand swatch and its hex.
  def swatch_id = "#{key}-swatch"

  # The element the derivation stream updates inside this group's panel.
  def controls_id = key == "advanced" ? "advanced-overrides" : "#{key}-controls"

  def summary
    case key
    when "brand" then color_name
    when "radius" then light["radius"].to_s
    when "advanced" then override_count.zero? ? "Set one color by hex" : "#{override_count} overridden"
    else SUMMARIES.fetch(key)
    end
  end

  # The brand color as the three numbers the sliders move.
  def primary = inputs.to_h["primary"].presence || light["primary"]

  # The brand color as a person writes it: the hex they typed while the primary still is that color, else the closest hex.
  def hex
    typed = inputs.to_h["primary_hex"]
    typed.present? && Themes::Oklch.parse(typed).to_s == brand_color.to_s ? typed : brand_color.to_hex
  rescue Themes::Oklch::Invalid
    brand_color.to_hex
  end

  def lightness = brand_color.lightness
  def chroma = brand_color.chroma
  def hue = brand_color.hue

  def tint = Float(inputs.to_h.fetch("tint") { Themes::Service::Harmony::DEFAULTS[:tint] })
  def radius_rem = Float(light["radius"].to_s.delete_suffix("rem"), exception: false) || 0.0

  # Whether the panel offers a way to Advanced: the groups whose variables are shown as read-only rows.
  def pinnable? = PINNABLE.include?(key)

  def variables = definition[:variables]
  def modes = MODES

  def rows
    variables.map do |variable|
      Row.new(name: "--#{variable}", light: light[variable], light_style: swatch(light[variable]), dark: dark[variable], dark_style: swatch(dark[variable]))
    end
  end

  # The theme page's full table; nil while the theme is unsaved (a derivation never has an id).
  def values_path = persisted? ? "#{helpers.theme_path(__getobj__)}#all-values" : nil

  # One field per overridable variable of the mode; a blank field is not an override.
  def overrides(mode)
    palette = mode == "dark" ? dark : light
    variables.reject { |variable| variable == "destructive" || (mode == "dark" && variable == "radius") }.map do |variable|
      override_row(mode, variable, palette[variable])
    end
  end

  def override_count = MODES.sum { |mode| stored_overrides(mode).size }

  private

  def definition = DEFINITIONS.fetch(key)

  # "Blue", "Dark blue", "Light yellow", "Gray": the primary in words a user would say.
  def color_name
    return neutral_name if chroma < GRAY_CHROMA

    hue_name = (HUE_NAMES.find { |bound, _name| hue < bound } || HUE_NAMES.first).last
    return hue_name.capitalize unless lightness < DARK_LIGHTNESS || lightness > LIGHT_LIGHTNESS

    "#{lightness < DARK_LIGHTNESS ? 'Dark' : 'Light'} #{hue_name}"
  end

  def neutral_name
    if lightness < BLACK_LIGHTNESS then "Black"
    elsif lightness > WHITE_LIGHTNESS then "White"
    else "Gray"
    end
  end

  def brand_color
    @brand_color ||= Themes::Oklch.parse(primary)
  rescue Themes::Oklch::Invalid
    Themes::Oklch.new(0.5, 0, 0)
  end

  # "Card text" for card-foreground, "Chart color 3" for chart-3; the CSS name when nothing better is known.
  def variable_label(variable)
    VARIABLE_LABELS.fetch(variable) do
      stem = variable.delete_suffix("-foreground")
      chart_number = variable[/\Achart-(\d)\z/, 1]
      next "Chart color #{chart_number}" if chart_number

      surface = SURFACE_NAMES[stem]
      next variable unless surface

      "#{surface} #{stem == variable ? 'background' : 'text'}"
    end
  end

  def swatch(value) = Themes::Presenter::Card.swatch_style(value)

  def override_row(mode, variable, derived)
    Override.new(mode: mode, name: "--#{variable}", label: variable_label(variable), derived: derived, value: stored_overrides(mode)[variable].to_s,
                 style: swatch(derived), field_name: "theme[inputs][overrides][#{mode}][#{variable}]", field_id: "override-#{mode}-#{variable}")
  end

  def stored_overrides(mode)
    stored = inputs.to_h["overrides"]
    stored.is_a?(Hash) ? (stored[mode] || {}).to_h.reject { |_name, value| value.blank? } : {}
  end
end
