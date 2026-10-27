# The request

Everything the wrapper sends. Verified against the `anthropic` gem 2.3 in the Gemfile.lock: `OutputConfig` takes `effort:` and `format_:` (sent as `format`), `JSONOutputFormat` takes `type: :json_schema` and `schema:`.

```ruby
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

def request(prompt)
  {
    model: MODEL,
    max_tokens: 16_000,
    system_: [ { type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } } ],
    messages: [ { role: "user", content: prompt } ],
    output_config: { effort: "low", format_: { type: :json_schema, schema: PALETTE_INPUTS_SCHEMA } }
  }
end
```

## The system prompt

Static text (so the cache hits): who the model is (a designer picking the inputs of a shadcn theme), what each input does (the summary of `theme-science`'s harmony rule in four sentences), the ranges, and three examples of prompt → inputs (a muted editorial theme, a saturated SaaS blue, a square high-contrast dark-first theme). It names the schema fields and nothing else: the model does not see the 32 variables and cannot "improve" them. Keep it under 1,500 tokens; it still clears the minimum cacheable prefix on this model, and a prompt that moves (a timestamp, the user's name) must stay out of it or the cache never hits.

## Reading the response

```ruby
case message.stop_reason
when :refusal   then message.stop_details&.category   # e.g. :general_harms; log it, do not retry
when :max_tokens then raise Generations::Truncated
when :end_turn  then JSON.parse(message.content.find { |block| block.type == :text }.text)
end
```

`content` is an array of typed blocks; `.type` is a Symbol. Thinking blocks may precede the text block (thinking is on by default on this model); do not assume `content.first` is the text.

## Errors

```ruby
rescue Anthropic::Errors::RateLimitError, Anthropic::Errors::APIConnectionError => e
  raise e                                 # the job retries these
rescue Anthropic::Errors::APIStatusError => e
  Rails.logger.error("generation #{generation.id}: #{e.class} #{e.status} #{e.type}")
  fail_with_code!(:unavailable)
rescue JSON::ParserError, Generations::Truncated => e
  Rails.logger.error("generation #{generation.id}: #{e.class}")
  fail_with_code!(:unavailable)
```

`APITimeoutError` is a subclass of `APIConnectionError`, so it is retried too. The SDK retries 408/409/429/5xx itself twice before raising; the job's `retry_on` adds the longer waits.

## Options not used in v1, and what turning them on takes

- **Refusal fallbacks**: `client.beta.messages.create(..., betas: ["server-side-fallback-2026-07-01"], fallbacks: "default")`; moves the call to the beta path. Add when refusals show up in the logs.
- **Streaming**: pointless for a 300-token JSON answer; the job waits.
- **Batches**: a generation is interactive.
- **Thinking display**: `thinking: { type: "adaptive", display: "summarized" }` returns a readable summary of the reasoning; not shown to the user in v1.
