# frozen_string_literal: true

class Views::Themes::Index::Card < Views::Base
  def initialize(card)
    @card = card
  end

  def view_template
    render Chadcn::Card.new(data: { testid: "theme-card" }) do |card|
      card.header do
        card.title { @card.name }
        card.description(class: "flex items-center gap-2") do
          span { @card.created_label }
          render Chadcn::Badge.new(variant: @card.badge_variant) { @card.status_label }
        end
      end
      card.content { render Components::Themes::SwatchStrip.new(swatches: @card.swatches, label: @card.swatches_label) }
      card.footer(class: "justify-end") do
        div(class: "flex items-center gap-2") do
          # The one control to the editor: the title is plain text.
          render Chadcn::Button.new(as_child: :a, href: @card.edit_path, variant: "outline", size: "sm", aria: { label: @card.edit_label }) { @card.edit_text }
          render Components::Editor::ExportDialog.new(presenter: @card.sharing, compact: true)
          render Components::Themes::DeleteButton.new(theme_id: @card.id, label: "Delete #{@card.name}", size: "sm")
        end
      end
    end
  end
end
