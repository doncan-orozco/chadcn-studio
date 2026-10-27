# frozen_string_literal: true

# One catalog entry: its title, scenario count and the demo rendered by the gem's tree renderer. A broken tree is shown as
# a notice (and reported) and never stops the rest of the gallery: the demo is captured first, so a tree that fails
# halfway leaves no unclosed markup behind.
class Components::Gallery::Entry < Components::Base
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
      div(class: "rounded-xl border bg-card p-6 text-card-foreground") { demo }
    end
  end

  private

  def demo
    # `capture` restores the buffer if the renderer raises; the captured HTML is Phlex output, already escaped.
    html = capture { render Chadcn::Catalog::TreeRenderer.new(tree: @entry.tree, component: @entry.component) }
    raw(safe(html))
  rescue Chadcn::Catalog::TreeRenderer::Error => error
    Rails.error.report(error, handled: true, context: { component: @entry.component })
    p(class: "text-sm text-destructive", role: "alert", data: { testid: "gallery-error" }) { "This demo could not be rendered: #{error.message}" }
  end
end
