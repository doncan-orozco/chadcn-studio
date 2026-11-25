# frozen_string_literal: true

class Components::Themes::DeleteButton < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  # Outline look in the destructive color; the dark: classes beat the outline variant's dark:border-input.
  DESTRUCTIVE_OUTLINE = "text-destructive hover:text-destructive border-destructive/50 dark:border-destructive/50 hover:bg-destructive/10 dark:hover:bg-destructive/20"

  def initialize(theme_id:, label: "Delete", size: "default", **attrs)
    @theme_id = theme_id
    @label = label
    @size = size
    @attrs = attrs
  end

  def view_template
    form(action: theme_path(@theme_id), method: "post", class: "inline", data: { turbo_confirm: "Delete this theme?" }) do
      input(type: "hidden", name: "_method", value: "delete")
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Chadcn::Button.new(type: "submit", variant: "outline", size: @size, class: [ DESTRUCTIVE_OUTLINE, @attrs[:class] ].compact.join(" "), aria: { label: @label }) { "Delete" }
    end
  end
end
