---
name: llm-generation
description: "Generating theme inputs from a prompt with Claude through the official `anthropic` Ruby gem in chadcn-studio: the client wrapper, the structured-output schema (a few palette inputs, never the full variable set), caching, refusal and error handling, the Solid Queue job with Turbo Stream delivery, the validate-and-repair pass, and how tests stub the client. Use when creating or editing `Generations::*`, `GenerateThemeJob`, the generation controller or anything that talks to the Anthropic API."
---

# LLM Generation

The user types a prompt ("warm editorial, terracotta, soft corners") and the app asks Claude for the **inputs** of the harmony rule (`theme-science` R7), not for a theme: a primary color, a tint strength, a radius and optional chart offsets. Ruby derives the palette, validates it with `Chadcn::Theme`, repairs it, saves it and pushes it to the editor, where the user keeps editing by hand. One request per generation, no agent loop, no tools.

## Quick Rules

Cite as `llm-generation R<n>`. Detail below and in references/call-shape.md.

R1. **Official SDK only.** Claude is called through the `anthropic` gem (`Anthropic::Client`); no raw HTTP, no other provider, no OpenAI-compatible shim. The client reads `ANTHROPIC_API_KEY` from the environment (or `Rails.application.credentials.anthropic_api_key` passed as `api_key:`); the key is never in the repository and never logged. → Client
R2. **One wrapper, injected.** `Generations::Service::Client` is the only file that references `Anthropic::`; it takes the client in `initialize` (default `Anthropic::Client.new`) and exposes `palette_inputs(prompt:) -> Result`. Operations receive it as a dependency (`operation-pattern` R4). → Client
R3. **Model and effort are constants.** `MODEL = :"claude-opus-5-5"`; `output_config: { effort: "low" }` (picking four numbers is a simple task; raise only after measuring). `thinking` is omitted (always on for this model); no `temperature`, `top_p` or `top_k`; no assistant prefill. → references/call-shape.md
R4. **Structured output, small schema.** The response is constrained with `output_config: { format_: { type: :json_schema, schema: PALETTE_INPUTS_SCHEMA } }` (the Ruby SDK spells the field `format_`, sent as `format`). The schema has `primary` (`l`, `c`, `h` numbers with the oklch ranges), `tint` (0..1), `radius_rem` (0..2), optional `chart_offsets` (five numbers) and a short `rationale` string; `additionalProperties: false`; never the 32 variables. → references/call-shape.md
R5. **Cache the system prompt.** The system prompt (the role, the harmony vocabulary, the ranges, three worked examples) is static, sent as `system_: [{ type: "text", text: SYSTEM_PROMPT, cache_control: { type: "ephemeral" } }]`; the user prompt goes in `messages`. Verify with `usage.cache_read_input_tokens` in a log line at debug level. → references/call-shape.md
R6. **Asynchronous.** The controller enqueues `GenerateThemeJob` through `Generations::Operation::Request` and answers with a pending Turbo Stream; the job runs `Generations::Operation::Complete`, which calls the client, derives, validates, saves and broadcasts. No LLM call inside a request. → `controller` R11, `jobs-and-mailers` R9
R7. **Handle the stop reason.** Read `message.stop_reason` before `content`: `:refusal` (log `stop_details.category`, fail with `:refused` and a user sentence), `:max_tokens` (fail with `:unavailable`, it means the schema or `max_tokens` is wrong), `:end_turn` (parse the text block as JSON). `max_tokens: 16000` is the default for a non-streaming call even though the answer is a few hundred tokens. → Outcomes
R8. **Untrusted until validated.** The parsed JSON goes through the same dry-validation contract as the editor form (`Themes::Contract::Inputs`), then `Themes::Service::Harmony`, then `Chadcn::Theme.validate(strict: true)` with the repair pass; a value that fails is never saved, previewed or exported. The model's `rationale` is shown as plain text (`textContent`), never as HTML. → `theme-science` R12
R9. **Error chain, most specific first.** `rescue Anthropic::Errors::RateLimitError` and `Anthropic::Errors::APIConnectionError` (retried by the job), then `Anthropic::Errors::APIStatusError` (log `e.type` and status, fail with `:unavailable`), then `JSON::ParserError` (fail with `:unavailable`); never a blanket `rescue StandardError` returning nil. → Outcomes
R10. **Tests never hit the network.** `test/support/fake_generation_client.rb` responds to `palette_inputs(prompt:)` with a fixed inputs hash, a refusal result or a raised SDK error; operation and job tests inject it; no test needs `ANTHROPIC_API_KEY`; `Anthropic::Client` is never constructed in the test environment (a guard in `Generations::Service::Client.new` raises when `Rails.env.test?` and no client was injected). → `testing` R8
R11. **One repair, then stop.** If the derived palette fails strict validation after the harmony repair, the operation does not re-prompt the model; it fails with `:contrast` and the user adjusts by hand. A second call would cost twice for a problem the rule already solves. → Outcomes
R12. **Fallbacks are a deliberate choice.** Server-side refusal fallbacks (`client.beta.messages.create` with `betas: ["server-side-fallback-2026-07-01"]` and `fallbacks: "default"`) are off in v1 because a theme prompt is rarely refused; turning them on is a documented change to the wrapper, not an ad-hoc edit. → references/call-shape.md

## Client

```ruby
# app/concepts/generations/service/client.rb
module Generations
  module Service
    class Client
      MODEL = :"claude-opus-5-5"
      Result = Struct.new(:inputs, :refusal_category, :usage, keyword_init: true)

      def initialize(client: nil, timeout: 60)
        raise ArgumentError, "inject a fake client in tests" if client.nil? && Rails.env.test?

        @client = client || Anthropic::Client.new(timeout: timeout)
      end

      def palette_inputs(prompt:)
        message = @client.messages.create(**request(prompt))
        return Result.new(refusal_category: message.stop_details&.category, usage: message.usage) if message.stop_reason == :refusal
        raise Generations::Truncated if message.stop_reason == :max_tokens

        text = message.content.find { |block| block.type == :text }.text
        Result.new(inputs: JSON.parse(text), usage: message.usage)
      end
    end
  end
end
```

The request hash is in references/call-shape.md. `Generations::Truncated` is a typed error of the app; the operation maps it to `:unavailable`.

## Outcomes

| Outcome | Where it is decided | Operation result |
|---|---|---|
| valid inputs | contract ok, harmony ok, strict validation ok | `{ model: generation, theme: theme }` and a broadcast |
| invalid after repair | `Chadcn::Theme.validate` strict | `Failure(code: :contrast, errors: [...])` |
| refusal | `stop_reason == :refusal` | `Failure(code: :refused, message: "...")` |
| rate limit / connection | SDK error, after the job's retries | `Failure(code: :unavailable)` |
| other API error, bad JSON, truncated | SDK error / parser / `:max_tokens` | `Failure(code: :unavailable)` with the error class logged |

The generation row records `completed_at`, `failed_at` and `failure_code` so the editor can show what happened and the user can retry.

## Cost

One call, cached system prompt, `effort: "low"`, a few hundred output tokens: well under a cent per generation at Opus 5.5 prices. Log `usage.input_tokens`, `usage.output_tokens`, `usage.cache_read_input_tokens` per generation at debug level; nothing else about the request is logged.

## Related
`theme-science` (what the inputs mean), `operation-pattern` (the two operations), `jobs-and-mailers` (the job and the broadcast), `testing` R8 (the fake client).
