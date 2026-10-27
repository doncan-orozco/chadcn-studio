# frozen_string_literal: true

# The harmony rule: a few inputs in, a whole shadcn palette out (theme-science R5, references/derivation.md).
# Pure: no I/O, no persistence. Contrast is judged only by Chadcn::Theme; this class only chooses and nudges lightness.
class Themes::Service::Harmony
  NEUTRAL_CHROMA_MAX = 0.015
  # Light muted-foreground is 0.54, not zinc's 0.552: 0.552 on the muted surface measures 4.37:1, under the 4.5:1 strict bar.
  LIGHT_STEPS = { "sidebar" => 0.985, "secondary" => 0.967, "muted" => 0.967, "accent" => 0.967,
                  "border" => 0.92, "input" => 0.92, "muted-foreground" => 0.54, "foreground" => 0.141,
                  "secondary-foreground" => 0.21, "accent-foreground" => 0.21 }.freeze
  DARK_STEPS = { "background" => 0.141, "card" => 0.21, "popover" => 0.21, "sidebar" => 0.21,
                 "secondary" => 0.274, "muted" => 0.274, "accent" => 0.274, "muted-foreground" => 0.705,
                 "foreground" => 0.985, "secondary-foreground" => 0.985, "accent-foreground" => 0.985 }.freeze
  MUTED_FOREGROUND_CHROMA_MIN = { light: 0.016, dark: 0.015 }.freeze
  DARK_PRIMARY_LIFT = 0.15
  DARK_PRIMARY_LIGHTNESS_MAX = 0.92
  DARK_PRIMARY_CHROMA = 0.8
  RING_LIGHTNESS = { light: 0.705, dark: 0.552 }.freeze
  RING_CHROMA = 0.6
  CHART_LIGHTNESS = { light: 0.65, dark: 0.70 }.freeze
  CHART_CHROMA_MIN = 0.12
  CHART_HUE_OFFSETS = [ -40, -20, 0, 20, 40 ].freeze
  DESTRUCTIVE = { light: "oklch(0.577 0.245 27.325)", dark: "oklch(0.704 0.191 22.216)" }.freeze
  DARK_ALPHA = { "border" => "oklch(1 0 0 / 10%)", "input" => "oklch(1 0 0 / 15%)" }.freeze
  FOREGROUND_LIGHTNESS = { light: 0.985, dark: 0.141 }.freeze
  REPAIR_STEP = 0.05
  REPAIR_MAX_STEPS = 10
  PRIMARY_REPAIR_SHIFT = 0.1
  DEFAULTS = { primary: "oklch(0.21 0.006 285.885)", tint: 0.4, radius: "0.625rem", chart_offsets: CHART_HUE_OFFSETS }.freeze
  MODES = { "light" => :root, "dark" => :dark }.freeze

  Derivation = Data.define(:palette, :repairs)

  def self.call(inputs) = derive(inputs).palette

  def self.derive(inputs) = new(inputs).derive

  def initialize(inputs)
    inputs = inputs.to_h.symbolize_keys
    @primary = Themes::Oklch.parse(inputs.fetch(:primary) { DEFAULTS[:primary] }.to_s)
    @tint = Float(inputs.fetch(:tint) { DEFAULTS[:tint] })
    @radius = inputs.fetch(:radius) { DEFAULTS[:radius] }.to_s
    @chart_offsets = (inputs[:chart_offsets] || DEFAULTS[:chart_offsets]).map { |offset| Float(offset) }
    @overrides = normalize_overrides(inputs[:overrides])
  end

  def derive
    palette = build(@primary)
    repairs = repair(palette)

    if primary_pair_failing?(palette)
      palette = build(shifted_primary)
      repairs += 1 + repair(palette)
    end

    Derivation.new(palette: palette, repairs: repairs)
  end

  private

  attr_reader :primary, :tint, :radius, :chart_offsets, :overrides

  def build(brand)
    palette = Chadcn::Theme::Palette.new(
      root: stringify(light_variables(brand)).merge("radius" => radius),
      dark: stringify(dark_variables(brand))
    )
    MODES.each { |mode, side| palette.public_send(side).merge!(overrides.fetch(mode)) }

    palette
  end

  def light_variables(brand)
    white = Themes::Oklch.new(1, 0, 0)
    foreground = neutral(LIGHT_STEPS["foreground"])
    base = {
      "background" => white, "card" => white, "popover" => white,
      "foreground" => foreground, "card-foreground" => foreground, "popover-foreground" => foreground,
      "primary" => brand, "primary-foreground" => foreground_for(brand)
    }
    %w[sidebar secondary muted accent border input].each { |name| base[name] = neutral(LIGHT_STEPS[name]) }
    base["sidebar-foreground"] = foreground
    %w[secondary accent].each { |name| base["#{name}-foreground"] = neutral(LIGHT_STEPS["#{name}-foreground"]) }
    base["muted-foreground"] = neutral(LIGHT_STEPS["muted-foreground"], MUTED_FOREGROUND_CHROMA_MIN[:light])

    shared_variables(base, brand, :light)
  end

  def dark_variables(brand)
    lifted = Themes::Oklch.new(
      [ brand.lightness + DARK_PRIMARY_LIFT, DARK_PRIMARY_LIGHTNESS_MAX ].min, brand.chroma * DARK_PRIMARY_CHROMA, brand.hue
    )
    base = { "primary" => lifted, "primary-foreground" => foreground_for(lifted) }
    (DARK_STEPS.keys - %w[muted-foreground]).each { |name| base[name] = neutral(DARK_STEPS[name]) }
    %w[card popover sidebar].each { |name| base["#{name}-foreground"] = neutral(DARK_STEPS["foreground"]) }
    base["muted-foreground"] = neutral(DARK_STEPS["muted-foreground"], MUTED_FOREGROUND_CHROMA_MIN[:dark])
    DARK_ALPHA.each { |name, value| base[name] = value }

    shared_variables(base, brand, :dark)
  end

  # ring, charts, the sidebar mirror and destructive follow the same rule in both modes.
  def shared_variables(base, brand, mode)
    chroma = brand.chroma * RING_CHROMA
    base["ring"] = Themes::Oklch.new(RING_LIGHTNESS[mode], chroma, brand.hue)
    chart_offsets.each_with_index do |offset, index|
      base["chart-#{index + 1}"] = Themes::Oklch.new(CHART_LIGHTNESS[mode], [ brand.chroma, CHART_CHROMA_MIN ].max, ((brand.hue + offset) % 360) + 0.0)
    end
    base["destructive"] = DESTRUCTIVE[mode]
    %w[primary primary-foreground accent accent-foreground border ring].each { |name| base["sidebar-#{name}"] = base[name] }

    base
  end

  def neutral(lightness, chroma_floor = 0) = Themes::Oklch.new(lightness, [ tint * NEUTRAL_CHROMA_MAX, chroma_floor ].max + 0.0, primary.hue)

  # The lighter or the darker text candidate, whichever reads better on the surface.
  def foreground_for(surface)
    candidates = [ Themes::Oklch.new(FOREGROUND_LIGHTNESS[:light], 0, 0), neutral(FOREGROUND_LIGHTNESS[:dark]) ]
    candidates.max_by { |candidate| Chadcn::Theme.contrast(candidate.to_s, surface.to_s) || 0 }
  end

  def stringify(variables) = variables.transform_values(&:to_s)

  # ---- repair -----------------------------------------------------------------------------------

  # Nudges failing, non-overridden foregrounds toward readability. MUTATES the palette in place; returns the steps taken.
  def repair(palette)
    MODES.sum do |mode, side|
      variables = palette.public_send(side)
      Chadcn::Theme::CONTRAST_PAIRS.sum do |foreground, surface|
        next 0 if overrides.fetch(mode).key?(foreground)

        nudge_pair(variables, foreground, surface)
      end
    end
  end

  # MUTATES variables in place. A non-oklch pair (e.g. a hex override) is not repairable: stop with the steps so far.
  def nudge_pair(variables, foreground, surface)
    steps = 0
    while failing?(variables[foreground], variables[surface]) && steps < REPAIR_MAX_STEPS
      color, surface_color = Themes::Oklch.parse(variables[foreground]), Themes::Oklch.parse(variables[surface])
      direction = color.lightness > surface_color.lightness ? 1 : -1
      moved = color.lighten(direction * REPAIR_STEP)
      break if moved == color

      variables[foreground] = moved.to_s
      steps += 1
    end

    steps
  rescue Themes::Oklch::Invalid
    steps
  end

  def failing?(foreground, surface)
    ratio = Chadcn::Theme.contrast(foreground, surface)
    !ratio.nil? && ratio < Chadcn::Theme::MIN_CONTRAST
  end

  def primary_pair_failing?(palette)
    MODES.values.any? { |side| failing?(palette.public_send(side)["primary-foreground"], palette.public_send(side)["primary"]) }
  end

  def shifted_primary
    shift = primary.lightness >= 0.5 ? PRIMARY_REPAIR_SHIFT : -PRIMARY_REPAIR_SHIFT
    primary.lighten(shift)
  end

  # ---- overrides --------------------------------------------------------------------------------

  def normalize_overrides(raw)
    raw = (raw || {}).to_h.stringify_keys
    MODES.keys.index_with { |mode| (raw[mode] || {}).to_h.to_h { |name, value| [ name.to_s, canonical(value) ] } }
  end

  def canonical(value)
    Themes::Oklch.parse(value).to_s
  rescue Themes::Oklch::Invalid
    value.to_s
  end
end
