# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-2xl space-y-6 p-8") do
      div(class: "space-y-2") do
        h1(class: "text-2xl font-semibold tracking-tight") { "Chadcn Studio" }
        p(class: "text-muted-foreground") { "Pick a color and get a whole shadcn theme." }
      end
      div(class: "flex flex-wrap items-center gap-3") do
        render Chadcn::Button.new(as_child: :a, href: new_theme_path) { "Create theme" }
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
        @presenter.cards.each do |card|
          li { a(href: card.edit_path, class: "flex min-h-8 w-full items-center rounded-md px-2 text-sm font-medium underline-offset-4 hover:underline focus-visible:underline focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none") { card.name } }
        end
      end
    end
  end
end
