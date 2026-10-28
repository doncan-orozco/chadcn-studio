# frozen_string_literal: true

class Views::Themes::New::Form < Views::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(theme, primary_example:)
    @theme = theme
    @primary_example = primary_example
  end

  def view_template
    form(action: themes_path, method: "post", class: "space-y-5", data: { testid: "new-theme-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      field(:name, "Name", value: @theme.name, placeholder: "Ocean", maxlength: 80, required: true)
      field(:primary, "Primary color", value: primary_value, placeholder: @primary_example, description: "An oklch color such as #{@primary_example}.", required: true)
      render Chadcn::Button.new(type: "submit") { "Create theme" }
    end
  end

  private

  def primary_value = @theme.inputs&.fetch("primary", nil) || @primary_example

  def field(attribute, label, description: nil, value: nil, **input)
    errors = @theme.errors[attribute]
    id = "theme-#{attribute}"
    render Chadcn::Field.new(data: { invalid: errors.any?.to_s }) do |field|
      field.label(html_for: id) { label }
      field.render Chadcn::Input.new(id: id, name: "theme[#{attribute}]", default_value: value, aria: { invalid: errors.any?.to_s, describedby: "#{id}-error" }, **input)
      field.description { description } if description
      field.error(id: "#{id}-error") { errors.to_sentence } if errors.any?
    end
  end
end
