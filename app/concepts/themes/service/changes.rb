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
    newly_pinned = pins_after.reject { |pin, value| pins_before[pin] == value }
    released = pins_before.except(*pins_after.keys)
    @pinned = variables(newly_pinned)
    @unpinned = variables(released)
    @pinned_modes = modes_by_variable(newly_pinned)
    @unpinned_modes = modes_by_variable(released)
  end

  def empty? = renamed_from.nil? && moved_inputs.empty? && pinned.empty? && unpinned.empty?

  def only_renamed? = !renamed_from.nil? && moved_inputs.empty? && pinned.empty? && unpinned.empty?

  # The one mode this save pinned (or released) a variable in, or nil when it did so in both.
  def pinned_mode(variable) = single_mode(@pinned_modes, variable)
  def unpinned_mode(variable) = single_mode(@unpinned_modes, variable)

  private

  # { [mode, variable] => value }
  def pins_in(overrides)
    overrides.to_h.flat_map { |mode, values| values.to_h.map { |variable, value| [ [ mode, variable ], value ] } }.to_h
  end

  def variables(pins) = pins.keys.map(&:last).uniq

  def modes_by_variable(pins) = pins.keys.group_by(&:last).transform_values { |pairs| pairs.map(&:first).uniq }

  def single_mode(modes_by_variable, variable)
    modes = modes_by_variable.fetch(variable, [])
    modes.first if modes.size == 1
  end

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
