# frozen_string_literal: true

class Views::Themes::New < Views::Base
  PRIMARY_EXAMPLE = "#1d4ed8"
  private_constant :PRIMARY_EXAMPLE

  # `generation_status` and `prompt` come back when a prompt was refused; the page is the same one that asked for it.
  def initialize(theme, generation_status: nil, prompt: nil, configured: Generations::Presenter::Panel.configured?)
    @theme = theme
    @generation_status = generation_status
    @prompt = prompt
    @configured = configured
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
      render Chadcn::Card.new(id: "describe") do |card|
        card.header do
          card.title { "Or describe it" }
          card.description { "Claude picks the colors from your words. You can adjust them in the editor." }
        end
        card.content { render Views::Themes::New::Describe.new(status: @generation_status, prompt: @prompt, configured: @configured) }
      end
    end
  end
end
