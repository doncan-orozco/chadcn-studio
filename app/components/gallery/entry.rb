# frozen_string_literal: true

# One catalog entry: its title, scenario count and the demo rendered by the gem's tree renderer. A broken tree is shown as
# a notice (and reported) and never stops the rest of the gallery: the demo is captured first, so a tree that fails
# halfway leaves no unclosed markup behind.
class Components::Gallery::Entry < Components::Base
  CARD_CLASSES = "rounded-xl border bg-card p-6 text-card-foreground"
  # The gem's Sidebar is `position: fixed`. `transform-gpu` makes the card its containing block and `overflow-hidden`
  # clips it, so it cannot cover the gallery index or the header. Other demos (popovers, menus) are left unclipped.
  CONTAINED_CARD_CLASSES = "relative transform-gpu overflow-hidden #{CARD_CLASSES}".freeze
  FIXED_POSITION_COMPONENTS = %w[sidebar].freeze
  private_constant :CARD_CLASSES, :CONTAINED_CARD_CLASSES, :FIXED_POSITION_COMPONENTS

  def initialize(entry:, anchor:, scenario_label:)
    @entry = entry
    @anchor = anchor
    @scenario_label = scenario_label
  end

  def view_template
    section(id: @anchor, class: "scroll-mt-6 space-y-3", data: { testid: "gallery-entry" }) do
      div(class: "flex items-baseline justify-between gap-4") do
        h3(class: "text-lg font-medium") { @entry.title }
        span(class: "text-xs text-muted-foreground") { @scenario_label }
      end
      div(class: card_classes, data: { testid: "gallery-card" }) { demo }
    end
  end

  private

  def card_classes = FIXED_POSITION_COMPONENTS.include?(@entry.component.to_s) ? CONTAINED_CARD_CLASSES : CARD_CLASSES

  def demo
    # `capture` restores the buffer if the renderer raises; the captured HTML is Phlex output, already escaped.
    html = capture { render Chadcn::Catalog::TreeRenderer.new(tree: @entry.tree, component: @entry.component) }
    raw(safe(html))
  rescue Chadcn::Catalog::TreeRenderer::Error => error
    Rails.error.report(error, handled: true, context: { component: @entry.component })
    p(class: "text-sm text-destructive", role: "alert", data: { testid: "gallery-error" }) { "This demo could not be rendered: #{error.message}" }
  end
end
