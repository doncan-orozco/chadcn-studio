# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  def view_template
    div(class: "mx-auto max-w-2xl space-y-2 p-8") do
      h1(class: "text-2xl font-semibold tracking-tight") { "Chadcn Studio" }
      p(class: "text-muted-foreground") { "Pick a color and get a whole shadcn theme." }
    end
  end
end
