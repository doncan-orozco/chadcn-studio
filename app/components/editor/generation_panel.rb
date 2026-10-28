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
        render Chadcn::Input.new(**prompt_attributes)
      end
      render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "generate" }) { "Generate" }
    end
    render Components::Editor::GenerationStatus.new(status: status)
  end

  private

  def status = @panel.status

  def prompt_attributes
    attributes = {
      id: "generation-prompt", name: @panel.prompt_param, maxlength: @panel.prompt_limit, required: true,
      placeholder: @panel.prompt_placeholder, class: "w-80", aria: { describedby: "generation_status" }
    }
    attributes[:aria][:invalid] = "true" if status&.failed?
    attributes
  end
end
