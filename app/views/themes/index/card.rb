# frozen_string_literal: true

class Views::Themes::Index::Card < Views::Base
  # The name opens the editor, and its ::after stretches the hit area over the whole card; the footer controls sit above it.
  TITLE_LINK = "inline-flex min-h-6 items-center text-primary underline underline-offset-4 focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none after:absolute after:inset-0 after:content-['']"

  def initialize(card)
    @card = card
  end

  def view_template
    render Chadcn::Card.new(class: "relative", data: { testid: "theme-card" }) do |card|
      card.header do
        card.title { a(href: @card.edit_path, class: TITLE_LINK) { @card.name } }
        card.description(class: "flex items-center gap-2") do
          span { @card.created_label }
          render Chadcn::Badge.new(variant: @card.badge_variant) { @card.status_label }
        end
      end
      card.content { render Components::Themes::SwatchStrip.new(swatches: @card.swatches, label: @card.swatches_label) }
      card.footer(class: "justify-end") do
        # relative lifts only the controls above the stretched title link; the rest of the footer still opens the editor.
        div(class: "relative flex items-center gap-2") do
          # A GET-form button, not a link: the title must stay the card's only link to the editor, so this footer control submits a GET.
          form(action: @card.edit_path, method: "get") do
            render Chadcn::Button.new(type: "submit", variant: "outline", size: "sm", aria: { label: @card.edit_label }) { @card.edit_text }
          end
          render Components::Editor::ExportDialog.new(presenter: @card.sharing(base_url: view_context.request.base_url), compact: true)
          render Components::Themes::DeleteButton.new(theme_id: @card.id, label: "Delete #{@card.name}", size: "sm")
        end
      end
    end
  end
end
