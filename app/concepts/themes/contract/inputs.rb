# frozen_string_literal: true

# The few choices the harmony rule needs (theme-science R7). Shape and ranges only; the derivation is the operation's.
class Themes::Contract::Inputs < Dry::Validation::Contract
  RADIUS = /\A\d+(?:\.\d+)?rem\z/
  CHART_OFFSETS_SIZE = 5
  MODES = %w[light dark].freeze
  OVERRIDABLE = (Chadcn::Theme::REQUIRED - %w[destructive]).freeze
  CHART_OFFSET_RANGE = (-360.0..360.0)
  # The only overrides that may carry alpha: the dark mode's translucent border and input.
  ALPHA_VARIABLES = { "dark" => %w[border input] }.freeze
  private_constant :RADIUS, :CHART_OFFSETS_SIZE, :MODES, :OVERRIDABLE, :CHART_OFFSET_RANGE, :ALPHA_VARIABLES

  params do
    required(:primary).filled(:string)
    optional(:tint).filled(:float, gteq?: 0, lteq?: 1)
    optional(:radius).filled(:string, format?: RADIUS)
    optional(:chart_offsets).array(:float).value(size?: CHART_OFFSETS_SIZE)
    optional(:overrides).value(:hash)
  end

  rule(:primary) do
    color = Themes::Oklch.parse(value)
    key.failure("must be an opaque oklch color that Chadcn::Theme can judge") if color.alpha || !judgeable?(color)
  rescue Themes::Oklch::Invalid
    key.failure("must be an oklch color such as oklch(0.55 0.2 250) with L 0..1, C 0..0.4, H 0..360")
  end

  rule(:chart_offsets) do
    next unless key? && value

    key.failure("each offset must be a finite number within -360..360") unless value.all? { |offset| offset.finite? && CHART_OFFSET_RANGE.cover?(offset) }
  end

  rule(:overrides) do
    next unless key? && value

    value.each do |mode, variables|
      next key.failure("mode #{mode.inspect} must be light or dark") unless MODES.include?(mode.to_s) && variables.respond_to?(:each_pair)

      variables.each_pair do |name, color|
        next key.failure("#{mode}: #{name.inspect} is not an overridable variable") unless OVERRIDABLE.include?(name.to_s)

        parsed = Themes::Oklch.parse(color)
        next if parsed.alpha && ALPHA_VARIABLES.fetch(mode.to_s, []).include?(name.to_s)

        key.failure("#{mode}: --#{name} must be an opaque oklch color that Chadcn::Theme can judge") if parsed.alpha || !judgeable?(parsed)
      rescue Themes::Oklch::Invalid
        key.failure("#{mode}: --#{name} must be an oklch color")
      end
    end
  end

  private

  # Chadcn::Theme is the only judge: judge the canonical spelling, which is what the harmony rule exports.
  def judgeable?(color) = !Chadcn::Theme.contrast(color.to_s, color.to_s).nil?
end
