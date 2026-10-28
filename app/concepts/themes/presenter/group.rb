# frozen_string_literal: true

# One group of the editor sidebar (Brand color, Surfaces and text...): its label, summary and the variables it covers.
# The partition comes from the gem's variable set (theme-science R1); nothing here derives or validates a color.
class Themes::Presenter::Group < Core::Presenter::Base
  COLORS = Chadcn::Theme::REQUIRED
  BRAND = %w[primary primary-foreground ring].freeze
  CHARTS = COLORS.grep(/\Achart-/).freeze
  SIDEBAR = COLORS.grep(/\Asidebar/).freeze
  SURFACES = (COLORS - BRAND - CHARTS - SIDEBAR).freeze
  RADIUS = Chadcn::Theme::ROOT_ONLY
  MODES = %w[light dark].freeze

  DEFINITIONS = {
    "brand" => { label: "Brand color", description: "Pick the primary color; the rest of the palette follows.", variables: BRAND },
    "surfaces" => { label: "Surfaces and text", description: "Backgrounds, cards, borders and the text on them.", variables: SURFACES },
    "radius" => { label: "Radius", description: "How round corners are.", variables: RADIUS },
    "charts" => { label: "Charts", description: "The five chart colors.", variables: CHARTS },
    "sidebar" => { label: "Sidebar", description: "The sidebar mirror of the palette.", variables: SIDEBAR },
    "dark" => { label: "Dark mode", description: "Preview the dark palette of this theme.", variables: [] },
    "advanced" => { label: "Advanced", description: "Pin a single variable; the others keep following the rule.", variables: COLORS + RADIUS }
  }.freeze
  KEYS = DEFINITIONS.keys.freeze

  Row = Data.define(:name, :light, :light_style, :dark, :dark_style)
  Override = Data.define(:mode, :name, :derived, :value, :style, :field_name, :field_id) do
    def overridden? = value.present?
  end

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

  def summary
    case key
    when "brand" then primary
    when "radius" then light["radius"].to_s
    when "dark" then "Light and dark palettes"
    when "advanced" then override_count.zero? ? "No overrides" : "#{override_count} overridden"
    else "#{variables.size} variables"
    end
  end

  # The brand color as the three numbers the sliders move.
  def primary = inputs.to_h["primary"].presence || light["primary"]

  def lightness = brand_color.lightness
  def chroma = brand_color.chroma
  def hue = brand_color.hue

  def tint = Float(inputs.to_h.fetch("tint") { Themes::Service::Harmony::DEFAULTS[:tint] })
  def radius_rem = Float(light["radius"].to_s.delete_suffix("rem"), exception: false) || 0.0

  def variables = definition[:variables]
  def modes = MODES

  def rows
    variables.map do |variable|
      Row.new(name: "--#{variable}", light: light[variable], light_style: swatch(light[variable]), dark: dark[variable], dark_style: swatch(dark[variable]))
    end
  end

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

  def brand_color
    @brand_color ||= Themes::Oklch.parse(primary)
  rescue Themes::Oklch::Invalid
    Themes::Oklch.new(0.5, 0, 0)
  end

  def swatch(value) = Themes::Presenter::Card.swatch_style(value)

  def override_row(mode, variable, derived)
    Override.new(mode: mode, name: "--#{variable}", derived: derived, value: stored_overrides(mode)[variable].to_s,
                 style: swatch(derived), field_name: "theme[inputs][overrides][#{mode}][#{variable}]", field_id: "override-#{mode}-#{variable}")
  end

  def stored_overrides(mode)
    stored = inputs.to_h["overrides"]
    stored.is_a?(Hash) ? (stored[mode] || {}).to_h.reject { |_name, value| value.blank? } : {}
  end
end
