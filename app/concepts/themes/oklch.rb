# frozen_string_literal: true

# Equality and hash compare the 3-decimal shadcn spelling.
# A color in oklch: L 0..1, C 0..0.4, H 0..360, optional alpha 0..100 (percent). `to_s` is the shadcn spelling.
# `parse` also reads an sRGB hex color (`#rrggbb`, `rrggbb`, `#rgb`) and converts it, so a color typed as hex is
# oklch from the first step on.
class Themes::Oklch
  class Invalid < ArgumentError; end

  NUMBER = /-?\d+(?:\.\d+)?|-?\.\d+/
  PATTERN = %r{\A\s*oklch\(\s*(#{NUMBER})\s+(#{NUMBER})\s+(#{NUMBER})(?:\s*/\s*(#{NUMBER})%)?\s*\)\s*\z}i
  LIGHTNESS = (0.0..1.0)
  CHROMA = (0.0..0.4)
  HUE = (0.0..360.0)
  ALPHA = (0.0..100.0)
  HEX = /\A\s*(?:#?(\h{6})|#(\h{3}))\s*\z/
  # Björn Ottosson's oklab matrices: linear sRGB -> LMS, then the cube roots of LMS -> Lab.
  LMS = [ [ 0.4122214708, 0.5363325363, 0.0514459929 ], [ 0.2119034982, 0.6806995451, 0.1073969566 ], [ 0.0883024619, 0.2817188376, 0.6299787005 ] ].freeze
  LAB = [ [ 0.2104542553, 0.7936177850, -0.0040720468 ], [ 1.9779984951, -2.4285922050, 0.4505937099 ], [ 0.0259040371, 0.7827717662, -0.8086757660 ] ].freeze
  # Below this chroma the color is a gray: its hue is noise, so it is spelled as 0.
  ACHROMATIC = 0.0005

  # The inverse of `LAB` (oklab -> cube roots of LMS) and of `LMS` (LMS -> linear sRGB).
  CONES = [ [ 1.0, 0.3963377774, 0.2158037573 ], [ 1.0, -0.1055613458, -0.0638541728 ], [ 1.0, -0.0894841775, -1.2914855480 ] ].freeze
  LINEAR_RGB = [ [ 4.0767416621, -3.3077115913, 0.2309699292 ], [ -1.2684380046, 2.6097574011, -0.3413193965 ], [ -0.0041960863, -0.7034186147, 1.7076147010 ] ].freeze

  private_constant :NUMBER, :PATTERN, :HEX, :LMS, :LAB, :ACHROMATIC, :CONES, :LINEAR_RGB

  attr_reader :lightness, :chroma, :hue, :alpha

  def self.parse(value)
    hex = HEX.match(value.to_s)
    return from_hex(hex[1] || hex[2].gsub(/\h/) { |digit| digit * 2 }) if hex

    match = PATTERN.match(value.to_s) or raise Invalid, "not a hex or oklch color: #{value.inspect}"

    new(*match.captures.compact.map { |number| Float(number) })
  end

  # Six hex digits of sRGB -> oklch.
  def self.from_hex(digits)
    linear = digits.scan(/\h\h/).map { |pair| linearize(pair.hex / 255.0) }
    cones = LMS.map { |row| Math.cbrt(weigh(row, linear)) }
    lightness, a, b = LAB.map { |row| weigh(row, cones) }
    chroma = Math.hypot(a, b)
    hue = chroma < ACHROMATIC ? 0.0 : Math.atan2(b, a) * 180 / Math::PI % 360

    new(lightness.clamp(LIGHTNESS.begin, LIGHTNESS.end), chroma < ACHROMATIC ? 0.0 : chroma, hue)
  end

  # oklch -> the three 0..255 sRGB channels, the inverse of `from_hex`; out-of-gamut channels are clamped.
  def self.to_srgb(lightness, chroma, hue)
    radians = hue * Math::PI / 180
    cones = CONES.map { |row| weigh(row, [ lightness, chroma * Math.cos(radians), chroma * Math.sin(radians) ])**3 }

    LINEAR_RGB.map { |row| srgb_channel(weigh(row, cones)) }
  end

  def self.srgb_channel(linear)
    linear = linear.clamp(0.0, 1.0)
    gamma = linear <= 0.0031308 ? linear * 12.92 : (1.055 * (linear**(1 / 2.4))) - 0.055

    (gamma * 255).round.clamp(0, 255)
  end

  def self.linearize(channel) = channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4

  def self.weigh(row, values) = row.zip(values).sum { |weight, value| weight * value }

  private_class_method :from_hex, :linearize, :weigh, :srgb_channel

  def initialize(lightness, chroma, hue, alpha = nil)
    @lightness = number!(:lightness, lightness, LIGHTNESS)
    @chroma = number!(:chroma, chroma, CHROMA)
    @hue = number!(:hue, hue, HUE)
    @alpha = alpha.nil? ? nil : number!(:alpha, alpha, ALPHA)
    freeze
  end

  def lighten(amount) = self.class.new((lightness + amount).clamp(LIGHTNESS.begin, LIGHTNESS.end), chroma, hue, alpha)

  def with_chroma(value) = self.class.new(lightness, value, hue, alpha)

  def to_s
    base = [ lightness, chroma, hue ].map { |value| format_number(value) }.join(" ")

    alpha ? "oklch(#{base} / #{format_number(alpha)}%)" : "oklch(#{base})"
  end

  # The sRGB hex spelling (`#rrggbb`), out-of-gamut channels clamped; the alpha is not part of it.
  def to_hex = format("#%02x%02x%02x", *self.class.to_srgb(lightness, chroma, hue))

  def ==(other) = other.is_a?(self.class) && to_s == other.to_s
  alias_method :eql?, :==

  def hash = to_s.hash

  private

  def number!(name, value, range)
    number = begin
      value.is_a?(String) && !value.match?(/\A#{NUMBER}\z/o) ? raise(ArgumentError) : Float(value)
    rescue ArgumentError, TypeError
      raise Invalid, "#{name} #{value.inspect} is not a number"
    end
    raise Invalid, "#{name} #{value.inspect} is outside #{range}" unless number.finite? && range.cover?(number)

    number
  end

  def format_number(value) = format("%.3f", value).sub(/\.?0+\z/, "")
end
