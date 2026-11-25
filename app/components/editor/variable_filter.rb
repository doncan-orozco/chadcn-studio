# frozen_string_literal: true

# The "Find a variable" field of Advanced: narrows the override rows by name as it is typed. It is not part of the form data,
# so its events stop here: typing a query is not an edit and must not reach the form's dirty tracking.
class Components::Editor::VariableFilter < Components::Base
  ID = "variable-filter"
  EMPTY = "No variable matches"
  ACTIONS = "input->editor--variable-filter#filter:stop change->editor--variable-filter#filter:stop " \
            "keydown.enter->editor--variable-filter#preventSubmit"

  def view_template
    div(class: "grid gap-1 pb-4") do
      render Chadcn::Label.new(html_for: ID, class: "text-sm") { "Find a variable" }
      render Chadcn::Input.new(
        id: ID, type: "search", placeholder: "primary, border, ring...", autocomplete: "off", spellcheck: "false",
        data: { editor__variable_filter_target: "query", action: ACTIONS }
      )
      p(class: "text-xs text-muted-foreground", role: "status", data: { editor__variable_filter_target: "status" })
    end
  end
end
