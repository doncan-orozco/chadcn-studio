# frozen_string_literal: true

# What a save changed in a theme: the old name, the inputs that moved, the variables pinned or released.
# Pure: two snapshots in (`{ name:, inputs: }`), no I/O. A variable pinned in light and dark is named once.
class Themes::Service::Changes
  TRACKED_INPUTS = %w[primary tint radius].freeze

  attr_reader :renamed_from, :inputs, :pinned, :unpinned

  def self.snapshot(theme) = { name: theme.name, inputs: theme.inputs.to_h.deep_dup }

  def self.between(before:, after:) = new(before: before, after: after)

  def initialize(before:, after:)
    @renamed_from = before[:name] unless before[:name] == after[:name]
    @inputs = TRACKED_INPUTS.reject { |key| before[:inputs][key] == after[:inputs][key] }
    pins_before = pins_in(before[:inputs]["overrides"])
    pins_after = pins_in(after[:inputs]["overrides"])
    @pinned = variables(pins_after.reject { |key, value| pins_before[key] == value })
    @unpinned = variables(pins_before.except(*pins_after.keys))
  end

  def empty? = renamed_from.nil? && inputs.empty? && pinned.empty? && unpinned.empty?

  private

  # { [mode, variable] => value }
  def pins_in(overrides)
    overrides.to_h.flat_map { |mode, variables| variables.to_h.map { |variable, value| [ [ mode, variable ], value ] } }.to_h
  end

  def variables(pins) = pins.keys.map(&:last).uniq
end
