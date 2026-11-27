# frozen_string_literal: true

# The prompt form of the editor ("warm editorial, terracotta") and the status of the last generation. A separate form from
# the toolbar's; it listens to the theme's stream, where the job reports back.
class Components::Editor::GenerationPanel < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::TurboStreamFrom

  # `primary` makes Generate the page's filled button: the editor keeps Save as its own, so there it stays an outline.
  def initialize(panel:, primary: false)
    @panel = panel
    @primary = primary
  end

  # A studio that cannot generate offers nothing to fill in: only the line that says why.
  def view_template
    return render(Components::Editor::GenerationStatus.new(status: status)) unless @panel.configured?

    turbo_stream_from @panel.stream_source if @panel.stream_source
    form(action: @panel.create_path, method: "post", class: "flex flex-wrap items-end gap-2", data: { testid: "generation-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      div(class: "grid gap-1") do
        render Chadcn::Label.new(html_for: "generation-prompt") { "Describe a theme" }
        render Chadcn::Input.new(**prompt_attributes)
      end
      render Chadcn::Button.new(type: "submit", variant: @primary ? "default" : "outline", data: { testid: "generate" }) { "Generate" }
    end
    render Components::Editor::GenerationStatus.new(status: status)
  end

  private

  def status = @panel.status

  def prompt_attributes
    attributes = {
      id: "generation-prompt", name: @panel.prompt_param, maxlength: @panel.prompt_limit, required: true,
      placeholder: @panel.prompt_placeholder, default_value: @panel.prompt, class: "w-80", aria: { describedby: "generation_status" }
    }
    attributes[:aria][:invalid] = "true" if status&.failed?
    attributes
  end
end
