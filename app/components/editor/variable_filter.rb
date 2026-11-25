# frozen_string_literal: true

# The "Find a variable" field of Advanced: narrows the override rows by name as it is typed. It is not part of the form data.
class Components::Editor::VariableFilter < Components::Base
  ID = "variable-filter"
  EMPTY = "No variable matches"

  def view_template
    div(class: "grid gap-1 pb-4") do
      render Chadcn::Label.new(html_for: ID, class: "text-sm") { "Find a variable" }
      render Chadcn::Input.new(
        id: ID, type: "search", placeholder: "primary, border, ring...", autocomplete: "off", spellcheck: "false",
        data: { editor__variable_filter_target: "query", action: "input->editor--variable-filter#filter keydown.enter->editor--variable-filter#preventSubmit" }
      )
      p(class: "text-xs text-muted-foreground", role: "status", data: { editor__variable_filter_target: "status" })
    end
  end
end
