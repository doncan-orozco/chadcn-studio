# frozen_string_literal: true

class Views::Themes::Index::Card < Views::Base
  def initialize(card)
    @card = card
  end

  def view_template
    render Chadcn::Card.new(data: { testid: "theme-card" }) do |card|
      card.header do
        card.title { a(href: @card.path, class: "hover:underline focus-visible:underline focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none") { @card.name } }
        card.description { @card.created_label }
      end
      card.content { render Components::Themes::SwatchStrip.new(swatches: @card.swatches, label: @card.swatches_label) }
      card.footer(class: "justify-between") do
        render Chadcn::Badge.new(variant: @card.badge_variant) { @card.status_label }
        render Chadcn::Button.new(as_child: :a, href: @card.edit_path, variant: "outline", size: "sm", aria: { label: @card.edit_label }) { "Edit" }
      end
    end
  end
end
