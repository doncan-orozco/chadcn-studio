# frozen_string_literal: true

# A name and a few inputs -> the saved theme, derived again. Reuses `Derive`, so nothing is saved unless the palette passes
# Chadcn::Theme strictly (theme-science R5). Inputs not posted keep their stored value, overrides included.
class Themes::Operation::Update < Core::Operation
  POSTED_INPUTS = %w[primary tint radius].freeze
  private_constant :POSTED_INPUTS

  def initialize(derive: Themes::Operation::Derive.new)
    @derive = derive
    super()
  end

  def call(model:, params:)
    params = params.to_h.stringify_keys
    model.name = params["name"].to_s.strip if params.key?("name")
    inputs = merged_inputs(model, (params["inputs"] || {}).to_h.stringify_keys)
    derivation = derive(model, inputs)
    model.assign_attributes(light: derivation[:palette].root, dark: derivation[:palette].dark, inputs: derivation[:inputs].deep_stringify_keys)
    model.save or fail_with_model!(model, code: :invalid)

    { model: model }
  end

  private

  def merged_inputs(model, posted)
    inputs = model.inputs.to_h.merge(posted.slice(*POSTED_INPUTS).compact_blank)
    inputs["overrides"] = pruned(posted["overrides"]) if posted.key?("overrides")
    inputs.compact_blank
  end

  # A cleared field is no override: the variable follows the rule again.
  def pruned(overrides)
    return {} unless overrides.respond_to?(:to_h)

    overrides.to_h.transform_values { |variables| variables.to_h.compact_blank }.compact_blank
  end

  def derive(model, inputs)
    outcome = @derive.call(inputs: inputs)
    return outcome.value! if outcome.success?

    failure = outcome.failure
    model.inputs = inputs
    inject_errors!(model, failure[:code] == :invalid ? failure[:errors] : { base: failure[:errors] })
    fail_with_model!(model, code: failure[:code])
  end
end
