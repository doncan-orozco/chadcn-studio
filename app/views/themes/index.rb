# frozen_string_literal: true

class Views::Themes::Index < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-6xl space-y-6 p-6") do
      header(class: "flex items-center justify-between gap-4") do
        div do
          h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
          p(class: "text-muted-foreground") { @presenter.summary }
        end
        render Chadcn::Button.new(as_child: :a, href: new_theme_path) { "New theme" }
      end

      @presenter.empty? ? empty : cards
    end
  end

  private

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
