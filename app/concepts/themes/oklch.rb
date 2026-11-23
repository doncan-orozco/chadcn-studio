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

  private_constant :NUMBER, :PATTERN, :HEX, :LMS, :LAB, :ACHROMATIC

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

  def self.linearize(channel) = channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4

  def self.weigh(row, values) = row.zip(values).sum { |weight, value| weight * value }

  private_class_method :from_hex, :linearize, :weigh

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
