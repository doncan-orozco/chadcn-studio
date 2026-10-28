# frozen_string_literal: true

class Components::Themes::DeleteButton < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(theme_id:)
    @theme_id = theme_id
  end

  def view_template
    form(action: theme_path(@theme_id), method: "post", class: "inline", data: { turbo_confirm: "Delete this theme?" }) do
      input(type: "hidden", name: "_method", value: "delete")
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Button.new(type: "submit", variant: "destructive") { "Delete" }
    end
  end
end
