# frozen_string_literal: true

# Publishes or unpublishes the theme: POST or DELETE on its publication, as the presenter says.
class Components::Editor::PublishToggle < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  # `attrs` go to the button (a `variant:`, a `data:` hash merged over the default test id).
  def initialize(presenter:, **attrs)
    @presenter = presenter
    @attrs = { variant: "outline", **attrs, data: { testid: "publish-toggle", **attrs.fetch(:data, {}) } }
  end

  def view_template
    form(action: @presenter.publication_path, method: "post", class: "inline") do
      input(type: "hidden", name: "_method", value: "delete") if @presenter.unpublish?
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Button.new(type: "submit", **@attrs) { @presenter.publication_label }
    end
  end
end
