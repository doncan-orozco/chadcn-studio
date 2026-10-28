# frozen_string_literal: true

# The index page: the recent themes as cards.
class Themes::Presenter::List
  attr_reader :cards

  def initialize(themes)
    @cards = Themes::Presenter::Card.wrap(themes)
  end

  def title = "Themes"
  def empty? = cards.empty?
  def summary = empty? ? "No themes yet." : "#{cards.size} #{cards.size == 1 ? 'theme' : 'themes'}, newest first."
end
