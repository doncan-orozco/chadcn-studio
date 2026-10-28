# frozen_string_literal: true

# Publishes or unpublishes the theme: two forms' worth of intent, two actions (POST / DELETE on the publication).
class Components::Editor::PublishToggle < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(theme:)
    @theme = theme
  end

  def view_template
    form(action: theme_publication_path(@theme), method: "post", class: "inline") do
      input(type: "hidden", name: "_method", value: "delete") if @theme.published?
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "publish-toggle" }) { @theme.published? ? "Unpublish" : "Publish" }
    end
  end
end
