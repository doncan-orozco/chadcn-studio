# frozen_string_literal: true

# The prompt form of the editor ("warm editorial, terracotta") and the status of the last generation. A separate form from
# the toolbar's; it listens to the theme's stream, where the job reports back.
class Components::Editor::GenerationPanel < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(panel:)
    @panel = panel
  end

  def view_template
    turbo_stream_from @panel.stream_source
    form(action: @panel.create_path, method: "post", class: "flex flex-wrap items-end gap-2", data: { testid: "generation-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      div(class: "grid gap-1") do
        render Chadcn::Label.new(html_for: "generation-prompt") { "Describe a theme" }
        render Chadcn::Input.new(id: "generation-prompt", name: "generation[prompt]", maxlength: 2000, required: true, placeholder: "warm editorial, terracotta, soft corners", class: "w-80")
      end
      render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "generate" }) { "Generate" }
    end
    render Components::Editor::GenerationStatus.new(status: @panel.status)
  end
end
