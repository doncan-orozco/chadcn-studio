# frozen_string_literal: true

# One catalog entry: its title and the demo rendered by the gem's tree renderer. A broken tree is shown as
# a notice (and reported) and never stops the rest of the gallery: the demo is captured first, so a tree that fails
# halfway leaves no unclosed markup behind.
class Components::Gallery::Entry < Components::Base
  CARD_CLASSES = "rounded-xl border bg-card p-6 text-card-foreground"
  # The gem's Sidebar is `position: fixed`. `transform-gpu` makes the card the containing block of fixed descendants and
  # `overflow-hidden` clips them, so the demo cannot cover the gallery index or the header. Known exception to
  # phlex-view-pattern R12: below `md` the gem mounts the Sidebar's mobile Sheet inside this card, so it opens confined to
  # the card (wanted for a specimen; the gallery has no stacked chrome there). A self-contained Sidebar catalog scenario
  # upstream would remove it. Other demos (popovers, menus) are left unclipped.
  CONTAINED_CARD_CLASSES = "transform-gpu overflow-hidden #{CARD_CLASSES}".freeze
  FIXED_POSITION_COMPONENTS = %w[sidebar].freeze
  # The entry title is an h3: demo headings go to h4 or deeper, so the page outline lists only the letter groups and component names.
  DEMO_HEADING_FLOOR = 4
  DEMO_HEADING_SELECTOR = "h1, h2, h3, h4, h5".freeze
  private_constant :CARD_CLASSES, :CONTAINED_CARD_CLASSES, :FIXED_POSITION_COMPONENTS, :DEMO_HEADING_FLOOR, :DEMO_HEADING_SELECTOR

  def initialize(entry:, anchor:, **attrs)
    @entry = entry
    @anchor = anchor
    @attrs = attrs
  end

  def view_template
    section(**@attrs.except(:data), id: @anchor, class: "scroll-mt-6 space-y-3", data: { testid: "gallery-entry" }.merge(@attrs.fetch(:data, {}))) do
      h3(class: "text-lg font-medium") { @entry.title }
      div(class: card_classes, data: { testid: "gallery-card" }) { demo }
    end
  end

  private

  def card_classes = FIXED_POSITION_COMPONENTS.include?(@entry.component.to_s) ? CONTAINED_CARD_CLASSES : CARD_CLASSES

  # Demo markup comes from the gem's catalog and is not ours to change, so it is made inert here: headings drop below the entry
  # title and links that would jump to the top (`#`) or to an anchor the demo does not hold lose their href.
  def contain_in_outline(html)
    fragment = Nokogiri::HTML5.fragment(html)
    fragment.css(DEMO_HEADING_SELECTOR).each { |heading| heading.name = "h#{heading_level(heading)}" }
    ids = fragment.css("[id]").map { |node| node["id"] }
    fragment.css("a[href^='#']").each { |link| link.remove_attribute("href") unless ids.include?(link["href"].delete_prefix("#")) }
    fragment.to_html
  end

  def heading_level(heading) = heading.name.delete_prefix("h").to_i.clamp(DEMO_HEADING_FLOOR, 6)

  def demo
    # `capture` restores the buffer if the renderer raises; the captured HTML is Phlex output, already escaped.
    html = capture { render Chadcn::Catalog::TreeRenderer.new(tree: @entry.tree, component: @entry.component) }
    raw(safe(contain_in_outline(html)))
  rescue Chadcn::Catalog::TreeRenderer::Error => error
    Rails.error.report(error, handled: true, context: { component: @entry.component })
    p(class: "text-sm text-destructive", role: "alert", data: { testid: "gallery-error" }) { "This demo could not be rendered: #{error.message}" }
  end
end
