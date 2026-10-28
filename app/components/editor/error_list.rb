# frozen_string_literal: true

# The messages of a rejected derivation or save, e.g. the text pairs that miss the contrast bar.
class Components::Editor::ErrorList < Components::Base
  def initialize(messages:)
    @messages = messages
  end

  def view_template
    return if @messages.empty?

    ul(class: "list-disc space-y-1 pl-5 text-sm text-destructive", data: { testid: "editor-error-list" }) do
      @messages.each { |message| li { message } }
    end
  end
end
