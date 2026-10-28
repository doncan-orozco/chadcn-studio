# frozen_string_literal: true

# Runs a pending generation: asks the client for palette inputs, derives and validates them like the editor does, saves the
# theme and the generation together, and tells the editor. One call to the model, one repair (the harmony rule's), never a
# second prompt (llm-generation R7, R8, R11).
class Generations::Operation::Complete < Core::Operation
  def initialize(client:, derive: Themes::Operation::Derive.new, fail_generation: Generations::Operation::Fail.new)
    @client = client
    @derive = derive
    @fail = fail_generation
    super()
  end

  def call(model:)
    return { model: model } unless model.pending?

    model.update!(started_at: Time.current)
    result = @client.palette_inputs(prompt: model.prompt)
    inputs = step accepted(model, result)
    derivation = step derived(model, inputs)
    persist(model, derivation, result.inputs)

    { model: model }
  end

  private

  def accepted(generation, result)
    if result.ok?
      inputs = theme_inputs(result.inputs)
      return inputs ? Success(inputs) : failed(generation, :invalid, detail: "answer not shaped like the schema")
    end

    code = result.status == :refused ? :refused : :unavailable
    failed(generation, code, detail: [ result.status, result.refusal_category ].compact.join(" "))
  end

  def derived(generation, inputs)
    outcome = @derive.call(inputs: inputs)
    return outcome if outcome.success?

    failed(generation, outcome.failure[:code] == :contrast ? :contrast : :invalid, detail: outcome.failure[:errors].inspect)
  end

  def failed(generation, code, detail:)
    Rails.logger.warn("generation #{generation.id}: #{code} #{detail}")
    @fail.call(model: generation, code: code)
    Failure(model: generation, code: code)
  end

  def persist(generation, derivation, raw)
    theme = generation.theme
    Generation.transaction do
      theme.update!(light: derivation[:palette].root, dark: derivation[:palette].dark, inputs: derivation[:inputs].deep_stringify_keys)
      generation.update!(completed_at: Time.current, inputs: raw)
    end
    Generations::Service::Broadcast.theme_changed(generation)
  end

  # The model's answer, as the inputs the editor form posts; nil when its JSON is not shaped like the schema.
  def theme_inputs(raw)
    return unless raw.is_a?(Hash) && raw["primary"].is_a?(Hash)

    primary = raw["primary"]
    {
      primary: Themes::Oklch.new(primary.fetch("l"), primary.fetch("c"), primary.fetch("h")).to_s,
      tint: raw["tint"],
      radius: "#{raw['radius_rem']}rem",
      chart_offsets: raw["chart_offsets"]
    }.compact
  rescue KeyError, Themes::Oklch::Invalid
    nil
  end
end
