# frozen_string_literal: true

# What the editor says about one generation: pending, done (with the model's rationale) or failed with a reason a person can act on.
class Generations::Presenter::Status < Core::Presenter::Base
  MESSAGES = {
    "refused" => "Claude declined this prompt. Try describing the theme differently.",
    "unavailable" => "Generation is unavailable right now. Try again in a moment.",
    "contrast" => "The generated colors do not meet the contrast bar. Try another prompt or adjust the theme by hand.",
    "invalid" => "Claude's answer was not a usable palette. Try another prompt.",
    "prompt" => "Describe the theme in 1 to 2000 characters."
  }.freeze
  private_constant :MESSAGES

  # `failure` is a code for a generation that never started (a prompt that was refused by the form).
  def initialize(generation, failure: nil)
    super(generation)
    @failure = failure
  end

  def state
    return :failed if @failure || failed?
    return :done if completed?

    :pending
  end

  def message
    case state
    when :pending then "Generating a theme from your prompt..."
    when :done then rationale.presence || "Theme generated."
    else MESSAGES.fetch((@failure || error_code).to_s, MESSAGES["unavailable"])
    end
  end

  def rationale = inputs.is_a?(Hash) ? inputs["rationale"].to_s : ""
end
