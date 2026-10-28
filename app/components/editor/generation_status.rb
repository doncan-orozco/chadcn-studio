# frozen_string_literal: true

# The status of a generation: pending, done or failed with its reason. Always renders the `generation_status` target
# so a stream can replace it. The model's text is plain text (llm-generation R8).
class Components::Editor::GenerationStatus < Components::Base
  def initialize(status: nil)
    @status = status
  end

  def view_template
    div(id: "generation_status", role: @status&.failed? ? "alert" : "status", class: classes, data: { testid: "generation-status", state: @status&.state }) do
      plain @status.message if @status
    end
  end

  private

  def classes
    base = "min-h-5 text-sm empty:hidden"
    @status&.failed? ? "#{base} text-destructive" : "#{base} text-muted-foreground"
  end
end
