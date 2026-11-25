# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  ROW_LINK = "flex min-h-8 w-full items-center gap-3 rounded-md px-2 text-sm font-medium hover:bg-accent focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none"

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-2xl space-y-6 p-8") do
      div(class: "space-y-2") do
        h1(class: "text-2xl font-semibold tracking-tight") { "Chadcn Studio" }
        p(class: "text-muted-foreground") { "Pick a color, or describe a theme, and get a whole shadcn theme." }
      end
      div(class: "flex flex-wrap items-center gap-3") do
        render Chadcn::Button.new(as_child: :a, href: new_theme_path) { "Create theme" }
        render Chadcn::Button.new(as_child: :a, href: new_theme_path(anchor: "describe"), variant: "outline") { "Describe a theme" }
        render Chadcn::Button.new(as_child: :a, href: themes_path, variant: "outline") { "Browse themes" }
        render Chadcn::Button.new(as_child: :a, href: gallery_path, variant: "outline") { "Browse components" }
      end
      your_themes unless @presenter.empty?
    end
  end

  private

  def your_themes
    section(class: "space-y-3") do
      h2(class: "text-lg font-semibold tracking-tight") { "Your themes" }
      ul(class: "space-y-2", aria: { label: "Your themes" }) do
        @presenter.cards.each { |card| li { theme_row(card) } }
      end
    end
  end

  # The whole row is the link: a swatch, the name underlined at rest, a chevron.
  def theme_row(card)
    a(href: card.edit_path, class: ROW_LINK) do
      span(class: "size-4 shrink-0 rounded-full border", style: card.swatches.find { |swatch| swatch.name == "primary" }&.style, aria: { hidden: "true" })
      span(class: "flex-1 text-primary underline underline-offset-4", data: { link_name: true }) { card.name }
      span(class: "text-muted-foreground after:content-['›']", aria: { hidden: "true" })
    end
  end
end
