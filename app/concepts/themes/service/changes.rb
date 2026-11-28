# frozen_string_literal: true

# What a save changed in a theme: the old name, the inputs that moved, the variables pinned or released.
# Pure: two snapshots in (`{ name:, inputs: }`), no I/O. A variable pinned in light and dark is named once.
# An input that was never stored reads as its default, and a number as the number, so a form that posts the default back
# (the tint slider always posts one) is not a change.
class Themes::Service::Changes
  TRACKED_INPUTS = %w[primary tint radius].freeze

  attr_reader :renamed_from, :moved_inputs, :pinned, :unpinned

  def self.snapshot(theme) = { name: theme.name, inputs: theme.inputs.to_h.deep_dup }

  def self.between(before:, after:) = new(before: before, after: after)
  private_class_method :new

  def initialize(before:, after:)
    @renamed_from = before[:name] unless before[:name] == after[:name]
    @moved_inputs = TRACKED_INPUTS.reject { |key| reading(key, before[:inputs][key]) == reading(key, after[:inputs][key]) }
    pins_before = pins_in(before[:inputs]["overrides"])
    pins_after = pins_in(after[:inputs]["overrides"])
    newly_pinned = pins_after.reject { |key, value| pins_before[key] == value }
    @pinned = variables(newly_pinned)
    @unpinned = variables(pins_before.except(*pins_after.keys))
    @modes_pinned = newly_pinned.keys.group_by(&:last).transform_values { |pairs| pairs.map(&:first).uniq }
  end

  def empty? = renamed_from.nil? && moved_inputs.empty? && pinned.empty? && unpinned.empty?

  # The one mode a pinned variable was pinned in, or nil when it was pinned in both.
  def single_mode(variable)
    modes = @modes_pinned.fetch(variable, [])
    modes.first if modes.size == 1
  end

  private

  # { [mode, variable] => value }
  def pins_in(overrides)
    overrides.to_h.flat_map { |mode, variables| variables.to_h.map { |variable, value| [ [ mode, variable ], value ] } }.to_h
  end

  def variables(pins) = pins.keys.map(&:last).uniq

  # The input as the derivation reads it: the default when never stored, a number as a Float, a radius as its rem number.
  def reading(key, value)
    value = Themes::Service::Harmony::DEFAULTS.fetch(key.to_sym) if value.nil? || value == ""
    case key
    when "tint" then Float(value, exception: false) || value
    when "radius" then Float(value.to_s.delete_suffix("rem"), exception: false) || value
    else value.to_s
    end
  end
end
