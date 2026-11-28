# frozen_string_literal: true

# The index page: the recent themes as cards.
class Themes::Presenter::List
  attr_reader :cards

  # `configured` is whether the studio can generate a theme from a description: when it cannot, no page offers it.
  # `fresh_ids` are the themes generated and not opened since: their cards say New.
  # `base_url` reaches every card, which builds its Export dialog from it.
  def initialize(themes, base_url:, fresh_ids: [], configured: Generations::Presenter::Panel.configured?)
    @cards = Themes::Presenter::Card.wrap(themes, base_url:, fresh_ids: Array(fresh_ids))
    @configured = configured
  end

  def describable? = @configured

  def intro = describable? ? "Pick a color, or describe a theme, and get a whole shadcn theme." : "Pick a color and get a whole shadcn theme."

  def title = "Themes"
  def document_title = Core::Presenter::Base.document_title(title)
  def empty? = cards.empty?
  def summary = empty? ? "No themes yet." : "#{cards.size} #{cards.size == 1 ? 'theme' : 'themes'}, newest first."

  # New theme is the list's one primary; each card's Edit stays outline.
  def new_theme_variant = "default"
end
