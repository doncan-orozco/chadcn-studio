# frozen_string_literal: true

# A labelled search field that narrows a list of rows as it is typed, used by two domains (the editor's variable rows and the
# gallery index). The Stimulus controller is still `editor--variable-filter`: moving it under a shared name would touch the
# editor's markup in files other work owns. `isolated` adds `:stop` to the input and change actions, for a field inside a
# form whose dirty tracking a query must not reach.
class Components::Shared::ListFilter < Components::Base
  def initialize(id:, label:, placeholder:, wrapper:, isolated: false)
    @id = id
    @label = label
    @placeholder = placeholder
    @wrapper = wrapper
    @isolated = isolated
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
    modifier = @isolated ? ":stop" : ""
    "input->editor--variable-filter#filter#{modifier} change->editor--variable-filter#filter#{modifier} " \
      "keydown.enter->editor--variable-filter#preventSubmit"
  end
end
