---
name: jobs-and-mailers
description: "Background jobs and external clients in chadcn-studio (Solid Queue on SQLite). Use when creating or editing files in `app/jobs/**` or an external client under `app/concepts/*/service/` (the Anthropic client). Covers thin job shells delegating to operations, idempotency, named queues, Turbo Stream delivery, and injected clients with timeouts. There are no mailers in v1."
---

# Jobs and External Clients (chadcn-studio)

## Applies to
- when: `app/jobs/**/*.rb`
- when: `app/mailers/**/*.rb`
- when: `app/views/**/*mailer*`
- when: `app/services/**/*.rb`
- when: `app/concepts/*/service/**/*.rb` matching `/Anthropic|Net::HTTP|Faraday|timeout/`
- companion: `operation-pattern` when matching `/Operation/`
- system-review: never
- note: External clients live under `app/concepts/*/service/` here (there is no `app/services/`); the content gate keeps pure-Ruby services such as the harmony rule out.

## Quick Rules
Cite as `jobs-and-mailers R<n>`. Detail and examples follow below.

R1. **Thin jobs.** A job parses its arguments, calls ONE operation, and returns; no business rules, no multi-step workflows in `perform`. → detail: Jobs
R2. **Queries belong to query objects.** Selection logic (`where/joins`) in a job moves to `app/concepts/*/query/`; the job iterates with `find_each`. → detail: Jobs
R3. **Pass ids, not records.** Enqueue primitives (ids, strings); reload inside `perform`; `discard_on ActiveRecord::RecordNotFound` when the record may vanish. → detail: Jobs
R4. **Idempotent and retry-safe.** Running a job twice must be harmless (check state before acting, no double-create); declare `retry_on`/`discard_on` deliberately: the generation job retries `Anthropic::Errors::RateLimitError` and `APIConnectionError` with backoff and discards nothing silently. → detail: Jobs
R5. **Enqueue after commit.** Never enqueue from inside a transaction; the operation enqueues after it commits. → detail: Jobs
R6. **Per-item isolation.** Sweepers rescue and log per item so one failure does not abort the batch; they never swallow errors silently. → detail: Jobs
R7. **Named queues.** Jobs declare `queue_as` (`:default`, `:generation`) matching `config/queue.yml`. → detail: Jobs
R8. **No request state in jobs.** Jobs run outside a request; everything they need arrives as arguments. → detail: Jobs
R9. **Deliver through Turbo Streams.** A job that changes what a page shows broadcasts a Turbo Stream (`Turbo::StreamsChannel.broadcast_replace_to`) rendering a Phlex component; it never pushes raw HTML strings. → detail: Delivery
R10. **Injected external clients.** External APIs are plain objects with the credential and timeouts injectable and no domain logic; callers pass them in or construct them at the operation boundary. The Anthropic client wrapper is `Generations::Service::Client`. → `llm-generation`
R11. **Failures are explicit.** A client never returns `nil` for every failure silently; it logs context-rich errors (no secrets, no prompt bodies at info level) and returns a result the caller can route on, or raises a typed error. → detail: External clients
R12. **No network I/O inside a DB transaction.** Call external services before or after the transaction (SQLite has a single writer). → detail: External clients
R13. **No mailers in v1.** There is no `app/mailers/`; when mail arrives, it gets its rules here (thin mailers, presenter-fed views, `deliver_later`). → detail: Mailers

## Jobs
Solid Queue runs on SQLite (`config/queue.yml`, `bin/jobs`); Mission Control is not mounted in v1. The one job of v1:

```ruby
class GenerateThemeJob < ApplicationJob
  queue_as :generation
  retry_on Anthropic::Errors::RateLimitError, wait: :polynomially_longer, attempts: 5
  retry_on Anthropic::Errors::APIConnectionError, wait: 10.seconds, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(generation_id)
    Generations::Operation::Complete.new.call(model: Generation.find(generation_id))
  end
end
```

The operation calls the client, validates the result through `Chadcn::Theme`, persists, and broadcasts the stream.

## Delivery
`Generations::Operation::Complete` ends with `Turbo::StreamsChannel.broadcast_replace_to(generation.theme, target: "generation_status", renderable: Components::Editor::GenerationStatus.new(generation: generation))`; the editor page subscribes with `turbo_stream_from @theme`.

## External clients
`app/concepts/generations/service/client.rb` wraps `Anthropic::Client`; see `llm-generation` for the call shape, the structured output schema and the error chain. Timeouts: the SDK's `timeout:` (seconds) is set explicitly; `max_retries` stays at the SDK default (2) and the job owns the longer retries.

## Related
`../operation-pattern/SKILL.md`, `../query-object-pattern/SKILL.md`, `../llm-generation/SKILL.md`, `../testing/SKILL.md`.
