# frozen_string_literal: true

# The toast after a save: "Ocean saved: primary changed, border pinned". Says what this save changed, not only whose theme it was.
# `changes` is the Update operation's account of the save (`renamed_from`, `inputs`, `pinned`, `unpinned`).
class Themes::Presenter::SavedNotice < Core::Presenter::Base
  MAX_NAMED_CHANGES = 3

  def initialize(theme, changes:)
    super(theme)
    @changes = changes
  end

  def to_s
    return "#{name} saved" if phrases.empty?

    named = phrases.first(MAX_NAMED_CHANGES)
    named << "#{phrases.size - MAX_NAMED_CHANGES} more" if phrases.size > MAX_NAMED_CHANGES
    "#{name} saved: #{named.join(', ')}"
  end

  private

  def phrases
    @phrases ||= [
      (@changes[:renamed_from] && "renamed from #{@changes[:renamed_from]}"),
      *@changes[:inputs].map { |key| "#{key} changed" },
      *@changes[:pinned].map { |variable| "#{variable} pinned" },
      *@changes[:unpinned].map { |variable| "#{variable} unpinned" }
    ].compact
  end
end
