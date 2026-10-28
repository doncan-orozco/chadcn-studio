# frozen_string_literal: true

# One form: the theme name and Save (PATCH) plus the hidden inputs the panels keep up to date. The panels are mounted into
# `#editor-panels`, inside this form, so their fields travel with both Save and the derivation request (`/derivations`).
class Views::Themes::Edit::Toolbar < Views::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    form(action: @presenter.save_path, method: "post", class: "flex flex-wrap items-end gap-3 border-b p-3", data: { editor__preview_target: "form", testid: "editor-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "theme[inputs][primary]", value: @presenter.primary, data: { editor__preview_target: "primaryField" })
      input(type: "hidden", name: "theme[inputs][radius]", value: @presenter.radius, data: { editor__preview_target: "radiusField" })
      name_field
      render Chadcn::Button.new(type: "submit", name: "_method", value: "patch", data: { testid: "save" }) { "Save" }
      derivation_submitters
      div(id: "editor-errors", role: "alert", class: "w-full empty:hidden", data: { testid: "editor-errors" }) do
        render Components::Editor::ErrorList.new(messages: @presenter.failures)
      end
      div(id: "editor-panels")
    end
  end

  private

  def name_field
    div(class: "grid gap-1") do
      render Chadcn::Label.new(html_for: "theme-name") { "Name" }
      render Chadcn::Input.new(id: "theme-name", name: "theme[name]", default_value: @presenter.name, maxlength: 80, required: true, class: "w-56")
    end
  end

  # Never clicked by a person: the preview controller submits the form through them (`requestSubmit(submitter)`),
  # one posting to /derivations and one asking for the brand controls to be redrawn at the new color.
  def derivation_submitters
    render Chadcn::Button.new(type: "submit", formaction: @presenter.derivations_path, tabindex: -1, aria: { hidden: "true" }, class: "hidden", data: { editor__preview_target: "derive" })
    render Chadcn::Button.new(type: "submit", formaction: @presenter.refresh_path, tabindex: -1, aria: { hidden: "true" }, class: "hidden", data: { editor__preview_target: "refresh" })
  end
end
