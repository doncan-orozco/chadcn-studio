# frozen_string_literal: true

class Views::Themes::New < Views::Base
  PRIMARY_EXAMPLE = "oklch(0.55 0.2 250)"
  private_constant :PRIMARY_EXAMPLE

  def initialize(theme)
    @theme = theme
  end

  def view_template
    div(class: "mx-auto max-w-xl space-y-6 p-6") do
      h1(class: "text-2xl font-semibold tracking-tight") { "New theme" }
      render Chadcn::Card.new do |card|
        card.header do
          card.title { "Name and primary color" }
          card.description { "The rest of the palette is derived from them." }
        end
        card.content { render Views::Themes::New::Form.new(@theme, primary_example: PRIMARY_EXAMPLE) }
      end
    end
  end
end
