# frozen_string_literal: true

# The index page: the recent themes as cards.
class Themes::Presenter::List
  attr_reader :cards

  # `configured` is whether the studio can generate a theme from a description: when it cannot, no page offers it.
  def initialize(themes, configured: Generations::Presenter::Panel.configured?)
    @cards = Themes::Presenter::Card.wrap(themes)
    @configured = configured
  end

  def describable? = @configured

  def title = "Themes"
  def empty? = cards.empty?
  def summary = empty? ? "No themes yet." : "#{cards.size} #{cards.size == 1 ? 'theme' : 'themes'}, newest first."

  # New theme is the list's one primary; each card's Edit stays outline.
  def new_theme_variant = "default"
end
