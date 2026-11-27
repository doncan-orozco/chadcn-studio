# frozen_string_literal: true

class Views::Themes::Index < Views::Base
  def initialize(presenter, deleted: nil)
    @presenter = presenter
    @deleted = deleted
  end

  def view_template
    div(class: "mx-auto max-w-6xl space-y-6 p-6") do
      header(class: "flex items-center justify-between gap-4") do
        div do
          h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
          p(class: "text-muted-foreground") { @presenter.summary }
        end
        div(class: "flex items-center gap-2") do
          render Chadcn::Button.new(as_child: :a, href: new_theme_path(anchor: Components::Editor::GenerationPanel::PROMPT_ID), variant: "outline", data: { turbo: "false" }) { "Describe a theme" } if @presenter.describable?
          render Chadcn::Button.new(as_child: :a, href: new_theme_path, variant: @presenter.new_theme_variant) { "New theme" }
        end
      end

      deleted_status
      @presenter.empty? ? empty : cards
    end
  end

  private

  # The lasting confirmation of a delete: the toast announces it and is gone in seconds; this status stays until the next visit.
  def deleted_status
    return if @deleted.blank?

    p(role: "status", class: "rounded-md border bg-muted px-3 py-2 text-sm", data: { testid: "deleted-status" }) { @deleted }
  end

  def cards
    ul(class: "grid gap-4 sm:grid-cols-2 lg:grid-cols-3", aria: { label: "Themes" }) do
      @presenter.cards.each { |card| li { render Views::Themes::Index::Card.new(card) } }
    end
  end

  def empty
    render Chadcn::Empty.new do |empty|
      empty.header do
        empty.title { "No themes yet" }
        empty.description { "Pick a primary color and get a whole theme." }
      end
    end
  end
end
