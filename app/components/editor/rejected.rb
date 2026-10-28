# frozen_string_literal: true

# The Turbo Stream of a rejected derivation: the failing messages (contrast pairs, out-of-range inputs). The preview keeps its palette.
class Components::Editor::Rejected < Components::Base
  register_element :turbo_stream

  def initialize(editor)
    @editor = editor
  end

  def view_template
    turbo_stream(action: "update", target: "editor-errors") do
      template { render Components::Editor::ErrorList.new(messages: @editor.failures) }
    end
  end
end
