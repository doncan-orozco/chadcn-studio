# frozen_string_literal: true

# The prompt form of the editor ("warm editorial, terracotta") and the status of the last generation. A separate form from
# the toolbar's; it listens to the theme's stream, where the job reports back.
class Components::Editor::GenerationPanel < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::TurboStreamFrom

  # The prompt field's id: Components::Editor::DescribeLink points its fragment at it.
  PROMPT_ID = "generation-prompt"

  # `primary` makes Generate the page's filled button: the editor keeps Save as its own, so there it stays an outline.
  def initialize(panel:, primary: false)
    @panel = panel
    @primary = primary
  end

  # A studio that cannot generate offers nothing to fill in: only the line that says why.
  def view_template
    if @panel.configured?
      turbo_stream_from @panel.stream_source if @panel.stream_source
      form(action: @panel.create_path, method: "post", class: "flex flex-wrap items-end gap-2", data: { testid: "generation-form" }) do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        div(class: "grid gap-1") do
          render Chadcn::Label.new(html_for: PROMPT_ID) { "Describe a theme" }
          render Chadcn::Input.new(**prompt_attributes)
        end
        render Chadcn::Button.new(type: "submit", variant: @primary ? "default" : "outline", data: { testid: "generate" }) { "Generate" }
      end
    end
    render Components::Editor::GenerationStatus.new(status: status, brand: @panel.brand_control)
  end

  private

  def status = @panel.status

  # scroll-mt-32 keeps the label and the card header above the field when a fragment link lands on it.
  def prompt_attributes
    attributes = {
      id: PROMPT_ID, name: @panel.prompt_param, maxlength: @panel.prompt_limit, required: true,
      placeholder: @panel.prompt_placeholder, default_value: @panel.prompt, class: "w-80 scroll-mt-32", aria: { describedby: "generation_status" }
    }
    attributes[:aria][:invalid] = "true" if status&.failed?
    attributes
  end
end
