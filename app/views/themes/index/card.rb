# frozen_string_literal: true

class Views::Themes::Index::Card < Views::Base
  # The name opens the editor, and its ::after stretches the hit area over the whole card; the footer controls sit above it.
  TITLE_LINK = "hover:underline focus-visible:underline focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none after:absolute after:inset-0 after:content-['']"

  def initialize(card)
    @card = card
  end

  def view_template
    render Chadcn::Card.new(class: "relative", data: { testid: "theme-card" }) do |card|
      card.header do
        card.title { a(href: @card.edit_path, class: TITLE_LINK) { @card.name } }
        card.description { @card.created_label }
      end
      card.content { render Components::Themes::SwatchStrip.new(swatches: @card.swatches, label: @card.swatches_label) }
      card.footer(class: "justify-between") do
        render Chadcn::Badge.new(variant: @card.badge_variant) { @card.status_label }
        # relative lifts only the control above the stretched title link; the rest of the footer still opens the editor.
        render Chadcn::Button.new(as_child: :a, href: @card.edit_path, variant: "outline", size: "sm", class: "relative", aria: { label: @card.edit_label }) { "Edit" }
      end
    end
  end
end
