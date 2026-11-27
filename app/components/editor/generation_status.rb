# frozen_string_literal: true

# The status of a generation: pending, done or failed with its reason. Always renders the `generation_status` target
# so a stream can replace it. The model's text is plain text (llm-generation R8). A failure is a destructive alert under
# the field that keeps the description and offers the way on: try again, or pick the primary color by hand; both actions
# are buttons that forward to the control that already exists. A studio without an API key is not an error: it says how
# to turn generation on as one muted line.
class Components::Editor::GenerationStatus < Components::Base
  # The prompt field (its form holds the CSRF token a streamed fragment cannot carry), and the way to the brand color that
  # "Pick a primary color instead" hands the click to: the editor's Brand group dialog trigger
  # (Components::Editor::GroupDialog, keyed by the group's panel_id), or on New theme the Brand color field, which the
  # forward controller focuses. Only the dialog claims to open one.
  PROMPT_FIELD = "#generation-prompt"
  BRAND_PANEL = "group-brand"
  BRAND = {
    dialog: { selector: "[data-testid='#{BRAND_PANEL}']", aria: { haspopup: "dialog", controls: BRAND_PANEL } },
    field: { selector: "#theme-primary", aria: {} }
  }.freeze
  LINK = "underline underline-offset-4"
  BASE = "min-h-5 text-sm empty:hidden"

  # `brand` defaults to the editor: the turbo-stream reply and the job broadcast only ever reach it.
  def initialize(status: nil, brand: :dialog)
    @status = status
    @brand = BRAND.fetch(brand)
  end

  def view_template
    alert = @status&.alert?
    div(id: "generation_status", role: alert ? nil : "status", class: classes(alert), data: { testid: "generation-status", state: @status&.state }) do
      if alert
        failure
      elsif @status
        plain @status.message
      end
    end
  end

  private

  def classes(alert) = alert ? BASE : "#{BASE} text-muted-foreground"

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
      color_button
    end
  end

  def retry_button
    render Chadcn::Button.new(type: "button", size: "sm", variant: "outline", data: forwarding(:submit, PROMPT_FIELD, testid: "generation-retry")) { "Try again" }
  end

  def color_button
    render Chadcn::Button.new(type: "button", size: "sm", variant: "link", class: LINK, aria: @brand[:aria], data: forwarding(:click, @brand[:selector], testid: "generation-pick-color")) { "Pick a primary color instead" }
  end

  def forwarding(method, selector, testid:)
    { testid: testid, controller: "editor--forward", action: "click->editor--forward#forward", editor__forward_method_value: method, editor__forward_selector_value: selector }
  end
end
