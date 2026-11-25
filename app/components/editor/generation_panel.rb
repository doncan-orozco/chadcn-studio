# frozen_string_literal: true

# "Describe a theme": a dialog with the prompt form ("warm editorial, terracotta") and the status of the last generation.
# A separate form from the toolbar's; it listens to the theme's stream, where the job reports back.
# The portal is force-mounted (in the body, outside the toolbar form) so `#generation_status` exists while the dialog is
# closed and a broadcast that lands then is not lost. A force-mounted modal would also mount its overlay and scroll lock
# while closed, so the dialog is non-modal (like the group panels) and the closed content is hidden by a class.
class Components::Editor::GenerationPanel < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::TurboStreamFrom

  PANEL = "data-[state=closed]:hidden"

  def initialize(panel:)
    @panel = panel
  end

  def view_template
    turbo_stream_from @panel.stream_source
    render Chadcn::Dialog.new(id: "generation-dialog", modal: false) do
      render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Button.new(variant: "outline", data: { testid: "describe" })) { "Describe a theme" }
      render Chadcn::Dialog::Portal.new(force_mount: true) do
        render Chadcn::Dialog::Content.new(class: PANEL, data: { testid: "generation-panel" }) do
          heading
          prompt_form
          render Components::Editor::GenerationStatus.new(status: status)
        end
      end
    end
  end

  private

  def status = @panel.status

  def heading
    render Chadcn::Dialog::Header.new do
      render(Chadcn::Dialog::Title.new { "Describe a theme" })
      render(Chadcn::Dialog::Description.new { "Say it in a few words and Claude derives the palette." })
    end
  end

  def prompt_form
    form(action: @panel.create_path, method: "post", class: "grid gap-2", data: { testid: "generation-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      div(class: "grid gap-1") do
        render Chadcn::Label.new(html_for: "generation-prompt") { "Prompt" }
        render Chadcn::Input.new(**prompt_attributes)
      end
      render Chadcn::Button.new(type: "submit", data: { testid: "generate" }) { "Generate" }
    end
  end

  def prompt_attributes
    attributes = {
      id: "generation-prompt", name: @panel.prompt_param, maxlength: @panel.prompt_limit, required: true,
      placeholder: @panel.prompt_placeholder, aria: { describedby: "generation_status" }
    }
    attributes[:aria][:invalid] = "true" if status&.failed?
    attributes
  end
end
