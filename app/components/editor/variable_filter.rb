# frozen_string_literal: true

# The "Find a variable" field of Advanced: narrows the override rows by name as it is typed. It is not part of the form data,
# so its events stop here: typing a query is not an edit and must not reach the form's dirty tracking.
class Components::Editor::VariableFilter < Components::Base
  ID = "variable-filter"
  EMPTY = "No variable matches"
  PLACEHOLDER = "primary, border, ring..."
  WRAPPER = "grid gap-1 pb-4"

  def view_template
    render Components::Shared::ListFilter.new(id: ID, label: "Find a variable", placeholder: PLACEHOLDER, wrapper: WRAPPER, isolated: true)
  end
end
