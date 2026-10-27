# frozen_string_literal: true

# Equality and hash compare the 3-decimal shadcn spelling.
# A color in oklch: L 0..1, C 0..0.4, H 0..360, optional alpha 0..100 (percent). `to_s` is the shadcn spelling.
class Themes::Oklch
  class Invalid < ArgumentError; end

  NUMBER = /-?\d+(?:\.\d+)?|-?\.\d+/
  PATTERN = %r{\A\s*oklch\(\s*(#{NUMBER})\s+(#{NUMBER})\s+(#{NUMBER})(?:\s*/\s*(#{NUMBER})%)?\s*\)\s*\z}i
  LIGHTNESS = (0.0..1.0)
  CHROMA = (0.0..0.4)
  HUE = (0.0..360.0)
  ALPHA = (0.0..100.0)

  private_constant :NUMBER, :PATTERN

  attr_reader :lightness, :chroma, :hue, :alpha

  def self.parse(value)
    match = PATTERN.match(value.to_s) or raise Invalid, "not an oklch color: #{value.inspect}"

    new(*match.captures.compact.map { |number| Float(number) })
  end

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
