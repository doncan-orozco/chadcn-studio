# frozen_string_literal: true

# Moves the headings of a gem demo below the entry title (an h3) so the page outline lists only the letter groups and
# component names. The whole set shifts by one offset, so the demo's own hierarchy (h2 > h3) is kept (h4 > h5). Links are untouched.
# The root fix is upstream (a heading offset in the gem's TreeRenderer); this class goes away then.
class Components::Gallery::DemoOutline
  FLOOR = 4
  MAX_LEVEL = 6
  HEADING_SELECTOR = "h1, h2, h3, h4, h5, h6".freeze
  private_constant :FLOOR, :MAX_LEVEL, :HEADING_SELECTOR

  def self.call(html) = new.call(html)

  def call(html)
    fragment = Nokogiri::HTML5.fragment(html)
    headings = fragment.css(HEADING_SELECTOR)
    return html if headings.empty?

    shift = FLOOR - headings.map { |heading| level(heading) }.min
    return html unless shift.positive?

    headings.each { |heading| heading.name = "h#{(level(heading) + shift).clamp(1, MAX_LEVEL)}" }
    fragment.to_html
  end

  private

  def level(heading) = heading.name.delete_prefix("h").to_i
end
