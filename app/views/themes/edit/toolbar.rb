# frozen_string_literal: true

# The toolbar row and the one form behind it: the theme name and Save (PATCH) plus the hidden inputs the panels keep up to date. The dialog groups are mounted into
# `#editor-panels`, inside this form, so their fields travel with both Save and the derivation request (`/derivations`); the inline
# brand group sits in the sidebar and writes the hidden primary field through the preview controller.
class Views::Themes::Edit::Toolbar < Views::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(presenter)
    @presenter = presenter
  end

  FORM_ID = "editor-form"
  private_constant :FORM_ID

  # One row of chrome: the title, the name and Save (form-associated to the form below) and, from the caller's block, the
  # buttons that are forms of their own (Publish, Export). The form itself holds the hidden inputs, the errors and the panels.
  def view_template(&)
    div(class: "flex flex-wrap items-end gap-3 border-b p-3", data: { action: "input->editor--preview#markDirty change->editor--preview#markDirty" }) do
      h1(class: "mr-2 self-center text-xl font-semibold tracking-tight") { @presenter.title }
      name_field
      render Chadcn::Button.new(type: "submit", form: FORM_ID, name: "_method", value: "patch", data: { testid: "save" }) { "Save theme" }
      unsaved_marker
      div(class: "ml-auto flex items-center gap-2", &)
    end
    editor_form
  end

  private

  def editor_form
    form(id: FORM_ID, action: @presenter.save_path, method: "post", data: { editor__preview_target: "form", action: "input->editor--preview#markDirty change->editor--preview#markDirty", testid: "editor-form" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "theme[inputs][primary]", value: @presenter.primary, data: { editor__preview_target: "primaryField" })
      input(type: "hidden", name: "theme[inputs][radius]", value: @presenter.radius, data: { editor__preview_target: "radiusField" })
      derivation_submitters
      div(id: "editor-errors", role: "alert", class: "w-full border-b p-3 empty:hidden", data: { testid: "editor-errors" }) do
        render Components::Editor::ErrorList.new(messages: @presenter.failures)
      end
      div(id: "editor-panels")
    end
  end

  # Shown by the preview controller once the editor differs from the stored theme (inside an always-present status region so it is announced),
  # and rendered visible when a rejected Save re-renders the form still holding the unsaved edits.
  def unsaved_marker
    span(role: "status", class: "self-center text-sm text-foreground/70") do
      span(hidden: !@presenter.failed?, data: { editor__preview_target: "unsaved", testid: "unsaved" }) { "Unsaved changes" }
    end
  end

  def name_field
    div(class: "grid gap-1") do
      render Chadcn::Label.new(html_for: "theme-name") { "Name" }
      render Chadcn::Input.new(id: "theme-name", name: "theme[name]", form: FORM_ID, default_value: @presenter.name, maxlength: 80, required: true, class: "w-56")
    end
  end

  # Never clicked by a person: the preview controller submits the form through them (`requestSubmit(submitter)`),
  # one posting to /derivations and one asking for the brand controls to be redrawn at the new color.
  def derivation_submitters
    render Chadcn::Button.new(type: "submit", formaction: @presenter.derivations_path, tabindex: -1, aria: { hidden: "true" }, class: "hidden", data: { editor__preview_target: "derive" })
    render Chadcn::Button.new(type: "submit", formaction: @presenter.refresh_path, tabindex: -1, aria: { hidden: "true" }, class: "hidden", data: { editor__preview_target: "refresh" })
  end
end
