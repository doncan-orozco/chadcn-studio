# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "mx-auto max-w-2xl space-y-6 p-8") do
      div(class: "space-y-2") do
        h1(class: "text-2xl font-semibold tracking-tight") { "Chadcn Studio" }
        p(class: "text-muted-foreground") { "Pick a color and get a whole shadcn theme." }
      end
      div(class: "flex flex-wrap items-center gap-3") do
        render Chadcn::Button.new(as_child: :a, href: new_theme_path) { "Create theme" }
        render Chadcn::Button.new(as_child: :a, href: themes_path, variant: "outline") { "Browse themes" }
      end
    end
  end
end
