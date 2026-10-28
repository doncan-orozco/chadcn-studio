# frozen_string_literal: true

# Publishes or unpublishes the theme: POST or DELETE on its publication, as the presenter says.
class Components::Editor::PublishToggle < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(presenter:)
    @presenter = presenter
  end

  def view_template
    form(action: @presenter.publication_path, method: "post", class: "inline") do
      input(type: "hidden", name: "_method", value: "delete") if @presenter.unpublish?
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "publish-toggle" }) { @presenter.publication_label }
    end
  end
end
