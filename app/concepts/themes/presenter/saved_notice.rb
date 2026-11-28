# frozen_string_literal: true

# The toast after a save: "Ocean saved: brand color changed, border pinned (light mode)". Says what this save changed, not only whose theme it was.
# `changes` is the Update operation's account of the save (a Themes::Service::Changes).
class Themes::Presenter::SavedNotice < Core::Presenter::Base
  MAX_NAMED_CHANGES = 3
  # The tracked inputs in the words of the controls that move them, not the stored key.
  INPUT_PHRASES = { "primary" => "brand color changed", "tint" => "backgrounds and cards tinted", "radius" => "corner radius changed" }.freeze

  def initialize(theme, changes:)
    super(theme)
    @changes = changes
  end

  def to_s
    return "#{name} saved" if @changes.empty?
    return "Renamed #{@changes.renamed_from} to #{name}" if only_renamed?

    named = phrases.first(MAX_NAMED_CHANGES)
    named << "#{phrases.size - MAX_NAMED_CHANGES} more" if phrases.size > MAX_NAMED_CHANGES
    "#{name} saved: #{named.join(', ')}"
  end

  private

  def only_renamed? = @changes.renamed_from && phrases.size == 1

  def phrases
    @phrases ||= [
      (@changes.renamed_from && "renamed from #{@changes.renamed_from}"),
      *@changes.moved_inputs.map { |key| INPUT_PHRASES.fetch(key) },
      *@changes.pinned.map { |variable| "#{variable_name(variable)} pinned#{mode_note(variable)}" },
      *@changes.unpinned.map { |variable| "#{variable_name(variable)} unpinned" }
    ].compact
  end

  def variable_name(variable) = Themes::Presenter::Variable.label(variable).downcase

  # "(light mode)" when the pin covers one mode only, so a person is not left thinking the other follows it.
  def mode_note(variable)
    mode = @changes.single_mode(variable)
    " (#{mode} mode)" if mode
  end
end
