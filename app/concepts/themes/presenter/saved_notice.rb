# frozen_string_literal: true

# The toast after a save: "Ocean saved: primary changed, border pinned". Says what this save changed, not only whose theme it was.
class Themes::Presenter::SavedNotice
  TRACKED_INPUTS = %w[primary tint radius].freeze
  MAX_NAMED_CHANGES = 3

  def self.for(theme, before:) = new(theme, before: before).to_s

  # `before` is what the theme held before the save: `{ name:, inputs: }`.
  def self.snapshot(theme) = { name: theme.name, inputs: theme.inputs.to_h.deep_dup }

  def initialize(theme, before:)
    @theme = theme
    @before = before
  end

  def to_s
    return "#{@theme.name} saved" if changes.empty?

    named = changes.first(MAX_NAMED_CHANGES)
    named << "#{changes.size - MAX_NAMED_CHANGES} more" if changes.size > MAX_NAMED_CHANGES
    "#{@theme.name} saved: #{named.join(', ')}"
  end

  private

  def changes
    @changes ||= renamed + changed_inputs + pinned + unpinned
  end

  def renamed = @theme.name == @before[:name] ? [] : [ "renamed from #{@before[:name]}" ]

  def changed_inputs
    TRACKED_INPUTS.filter_map { |key| "#{key} changed" if @theme.inputs[key] != @before[:inputs][key] }
  end

  def pinned = names_of(now.reject { |key, value| was[key] == value }).map { |name| "#{name} pinned" }

  def unpinned = names_of(was.except(*now.keys)).map { |name| "#{name} unpinned" }

  def was = @was ||= pins(@before[:inputs]["overrides"])

  def now = @now ||= pins(@theme.inputs["overrides"])

  def names_of(pins) = pins.keys.map(&:last).uniq

  # { [mode, variable] => value }
  def pins(overrides)
    overrides.to_h.flat_map { |mode, variables| variables.to_h.map { |name, value| [ [ mode, name ], value ] } }.to_h
  end
end
