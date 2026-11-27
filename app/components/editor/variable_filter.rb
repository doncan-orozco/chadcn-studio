# frozen_string_literal: true

# The "Find a variable" field of Advanced: narrows the override rows by name as it is typed. It is not part of the form data,
# so its events stop here: typing a query is not an edit and must not reach the form's dirty tracking.
class Components::Editor::VariableFilter < Components::Base
  ID = "variable-filter"
  EMPTY = "No variable matches"
  PLACEHOLDER = "primary, border, ring..."
  WRAPPER = "grid gap-1 pb-4"

  # The defaults are the editor's field; another list (the gallery index) names its own id, label, placeholder and
  # wrapper classes, and passes `stop: false` when its events have no form to stay out of.
  def initialize(id: ID, label: "Find a variable", placeholder: PLACEHOLDER, wrapper: WRAPPER, stop: true)
    @id = id
    @label = label
    @placeholder = placeholder
    @wrapper = wrapper
    @stop = stop
  end

  def view_template
    div(class: @wrapper) do
      render Chadcn::Label.new(html_for: @id, class: "text-sm") { @label }
      render Chadcn::Input.new(
        id: @id, type: "search", placeholder: @placeholder, autocomplete: "off", spellcheck: "false",
        data: { editor__variable_filter_target: "query", action: actions }
      )
      p(class: "text-xs text-muted-foreground", role: "status", data: { editor__variable_filter_target: "status" })
    end
  end

  private

  def actions
    modifier = @stop ? ":stop" : ""
    "input->editor--variable-filter#filter#{modifier} change->editor--variable-filter#filter#{modifier} " \
      "keydown.enter->editor--variable-filter#preventSubmit"
  end
end
