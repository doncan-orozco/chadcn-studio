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
      labelled_input(:name, "Name", value: @theme.name, placeholder: "Ocean", maxlength: 80, required: true)
      labelled_input(:primary, "Primary color", value: primary_value, placeholder: @primary_example, description: "Your brand color, e.g. #{@primary_example}. oklch(...) works too.", required: true)
      p(class: "text-sm text-foreground/70", data: { testid: "required-legend" }) do
        asterisk
        plain " Required"
      end
      render Chadcn::Button.new(type: "submit") { "Create theme" }
    end
  end

  private

  # Nothing is prefilled: a default color would be saved as the brand color by a user who never looked at the field.
  def primary_value = @theme.inputs&.fetch("primary", nil)

  def labelled_input(attribute, label, description: nil, value: nil, required: false, **input)
    errors = @theme.errors[attribute]
    id = "theme-#{attribute}"
    render Chadcn::Field.new(data: { invalid: errors.any?.to_s }) do |field|
      field.label(html_for: id) { required_label(label, required) }
      field.render Chadcn::Input.new(id: id, name: "theme[#{attribute}]", default_value: value, required: required, aria: { invalid: errors.any?.to_s, describedby: described_by(id, errors, description) }, **input)
      field.description(id: "#{id}-description") { description } if description && errors.none?
      field.error(id: "#{id}-error") { errors.to_sentence } if errors.any?
    end
  end

  # The asterisk is decoration: the input's `required` attribute is what assistive technology announces.
  def required_label(label, required)
    plain label
    return unless required

    plain " "
    asterisk
  end

  def asterisk = span(class: "text-destructive", aria_hidden: "true") { "*" }

  def described_by(id, errors, description)
    [ ("#{id}-description" if description && errors.none?), ("#{id}-error" if errors.any?) ].compact.join(" ").presence
  end
end
