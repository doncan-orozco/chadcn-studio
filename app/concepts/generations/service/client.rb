# frozen_string_literal: true

# The one wrapper around the Anthropic SDK (llm-generation R1, R2): one call, the cached static system prompt, a small JSON
# schema. It returns what the model said as a Result and never judges it; rate limits and connection errors are raised as
# `Generations::Transient` for the job to retry.
class Generations::Service::Client
  MODEL = :"claude-opus-5-5"
  MAX_TOKENS = 16_000
  TIMEOUT = 60

  # `status` is :ok, :refused, :truncated or :unavailable.
  Result = Struct.new(:status, :inputs, :refusal_category, :usage, keyword_init: true) do
    def ok? = status == :ok
  end

  PALETTE_INPUTS_SCHEMA = {
    type: "object",
    additionalProperties: false,
    required: %w[primary tint radius_rem rationale],
    properties: {
      primary: {
        type: "object", additionalProperties: false, required: %w[l c h],
        properties: {
          l: { type: "number", minimum: 0, maximum: 1, description: "oklch lightness" },
          c: { type: "number", minimum: 0, maximum: 0.4, description: "oklch chroma" },
          h: { type: "number", minimum: 0, maximum: 360, description: "oklch hue in degrees" }
        }
      },
      tint: { type: "number", minimum: 0, maximum: 1, description: "how much of the primary hue the neutrals carry; 0.4 is the shadcn zinc look" },
      radius_rem: { type: "number", minimum: 0, maximum: 2, description: "corner radius in rem; 0.625 is the shadcn default, 0 is square" },
      chart_offsets: {
        type: "array", minItems: 5, maxItems: 5,
        items: { type: "number", minimum: -180, maximum: 180 },
        description: "hue offsets of the five chart colors relative to the primary hue"
      },
      rationale: { type: "string", maxLength: 280, description: "one sentence a designer would say about the choice" }
    }
  }.freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a product designer choosing the inputs of a shadcn/ui theme. You never write the theme itself: a deterministic rule derives every color from your inputs.

    Inputs:
    - primary: the brand color in oklch. l is lightness 0..1 (0.45-0.65 reads as a solid brand color), c is chroma 0..0.4 (0.02 is nearly gray, 0.2 is vivid), h is the hue angle 0..360 (30 red-orange, 90 yellow, 150 green, 200 cyan, 250 blue, 300 purple).
    - tint: 0..1, how much of the primary hue the neutral surfaces carry. 0 is pure gray, 0.4 is the shadcn zinc look, 1 is strongly colored surfaces.
    - radius_rem: corner radius in rem. 0 is square, 0.625 is the shadcn default, 1.5 is pill-like.
    - chart_offsets: optional, five hue offsets in degrees relative to the primary hue for the chart colors. Omit it unless the prompt asks for a specific chart mood.
    - rationale: one plain sentence a designer would say about the choice. No markup.

    Examples:
    Prompt: warm editorial, terracotta, soft corners
    Answer: {"primary":{"l":0.58,"c":0.13,"h":45},"tint":0.3,"radius_rem":0.75,"rationale":"A muted terracotta primary on warm paper-like neutrals with gentle corners."}

    Prompt: saturated SaaS blue, clean
    Answer: {"primary":{"l":0.55,"c":0.22,"h":260},"tint":0.15,"radius_rem":0.5,"rationale":"A confident saturated blue with near-neutral surfaces and a modest radius."}

    Prompt: square, high contrast, dark-first, acid green
    Answer: {"primary":{"l":0.85,"c":0.25,"h":135},"tint":0.05,"radius_rem":0,"rationale":"Acid green on almost colorless surfaces with square corners for a stark look."}

    Answer only with the JSON object of the schema.
  PROMPT

  def initialize(client: nil, timeout: TIMEOUT)
    raise ArgumentError, "inject a fake client in tests" if client.nil? && Rails.env.test?

    @client = client || Anthropic::Client.new(timeout: timeout)
  end

  def palette_inputs(prompt:)
    message = @client.messages.create(**request(prompt))
    read(message)
  rescue Anthropic::Errors::RateLimitError, Anthropic::Errors::APIConnectionError => error
    raise Generations::Transient, error.class.name
  rescue Anthropic::Errors::APIStatusError => error
    Rails.logger.error("generation: #{error.class} #{error.status} #{error.type}")
    Result.new(status: :unavailable)
  rescue JSON::ParserError => error
    Rails.logger.error("generation: #{error.class}")
    Result.new(status: :unavailable)
  end

  private

  def request(prompt)
    {
      model: MODEL,
      max_tokens: MAX_TOKENS,
      system_: [ { type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } } ],
      messages: [ { role: "user", content: prompt } ],
      output_config: { effort: "low", format_: { type: :json_schema, schema: PALETTE_INPUTS_SCHEMA } }
    }
  end

  def read(message)
    log_usage(message.usage)
    case message.stop_reason
    when :refusal then Result.new(status: :refused, refusal_category: message.stop_details&.category, usage: message.usage)
    when :max_tokens then Result.new(status: :truncated, usage: message.usage)
    when :end_turn then answer(message)
    else Result.new(status: :unavailable, usage: message.usage)
    end
  end

  def answer(message)
    block = message.content.find { |content| content.type == :text }
    return Result.new(status: :unavailable, usage: message.usage) unless block

    Result.new(status: :ok, inputs: JSON.parse(block.text), usage: message.usage)
  end

  def log_usage(usage)
    return unless usage

    Rails.logger.debug { "generation usage: in=#{usage.input_tokens} out=#{usage.output_tokens} cache_read=#{usage.cache_read_input_tokens}" }
  end
end
