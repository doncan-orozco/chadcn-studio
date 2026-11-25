# frozen_string_literal: true

# The other way to start a theme: describe it and let Claude derive the palette. Posts to a collection that creates the theme.
class Views::Themes::New::Describe < Views::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(status:, prompt:, configured:)
    @status = status
    @prompt = prompt
    @configured = configured
  end

  def view_template
    form(action: generations_path, method: "post", class: "space-y-5", data: { testid: "describe-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Field.new do |field|
        field.label(html_for: "generation-prompt") { "Describe a theme" }
        field.render Chadcn::Input.new(**prompt_attributes)
      end
      render Components::Editor::GenerationStatus.new(status: status)
      render Chadcn::Button.new(type: "submit", disabled: !@configured, data: { testid: "generate" }) { "Generate" }
    end
  end

  private

  def status
    return Generations::Presenter::Status.new(Generation.new, failure: :not_configured) unless @configured

    @status
  end

  def prompt_attributes
    attributes = {
      id: "generation-prompt", name: "generation[prompt]", default_value: @prompt, maxlength: Generations::Presenter::Status::PROMPT_LIMIT,
      required: true, placeholder: "warm editorial, terracotta, soft corners", disabled: !@configured, aria: { describedby: "generation_status" }
    }
    attributes[:aria][:invalid] = "true" if @configured && @status&.failed?
    attributes
  end
end
