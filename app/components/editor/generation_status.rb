# frozen_string_literal: true

# The status of a generation: pending, done or failed with its reason. Always renders the `generation_status` target
# so a stream can replace it. The model's text is plain text (llm-generation R8). A failure is a destructive alert under
# the field that keeps the description and offers the way on: try again, or pick the primary color by hand.
class Components::Editor::GenerationStatus < Components::Base
  # The prompt field's form and the Brand group's trigger, which the two actions hand the click to (the status sits
  # outside the form, and a streamed fragment cannot carry a form's CSRF token).
  PROMPT_FIELD = "#generation-prompt"
  BRAND_TRIGGER = "[data-testid='group-brand']"

  def initialize(status: nil)
    @status = status
  end

  def view_template
    div(id: "generation_status", role: failed? ? nil : "status", class: classes, data: { testid: "generation-status", state: @status&.state }) do
      if failed?
        failure
      elsif @status
        plain @status.message
      end
    end
  end

  private

  def failed? = @status&.failed?

  def classes
    failed? ? "min-h-5 text-sm empty:hidden" : "min-h-5 text-sm empty:hidden text-muted-foreground"
  end

  def failure
    render Chadcn::Alert.new(variant: :destructive) do |alert|
      render Chadcn::Icon.new(:circle_alert)
      alert.description do
        p { @status.message }
        p { "Your description is kept in the field." } if @status.retryable?
        actions
      end
    end
  end

  def actions
    div(class: "flex flex-wrap items-center gap-2 pt-1") do
      retry_button if @status.retryable?
      color_link
    end
  end

  def retry_button
    render Chadcn::Button.new(type: "button", size: "sm", variant: "outline", data: forwarding(:submit, PROMPT_FIELD, testid: "generation-retry")) { "Try again" }
  end

  def color_link
    a(href: "#group-brand", class: Chadcn::Button.variants(variant: "link", size: "sm"), data: forwarding(:click, BRAND_TRIGGER, testid: "generation-pick-color")) { "Pick a primary color instead" }
  end

  def forwarding(method, selector, testid:)
    { testid: testid, controller: "editor--forward", action: "click->editor--forward#forward", editor__forward_method_value: method, editor__forward_selector_value: selector }
  end
end
