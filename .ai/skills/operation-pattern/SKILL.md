---
name: operation-pattern
description: "Golden archetype for write Operations and Contracts in chadcn-studio. Use when creating, editing or reviewing files in `app/concepts/*/operation/` or `app/concepts/*/contract/`: single-intent commands, explicit dependencies, transactions, `Core::Operation` result payloads, failure codes, and layered validation (dry-validation + ActiveModel errors)."
---

# Golden Operation Skill (chadcn-studio)

Use this skill whenever you create, edit, or review a mutation flow in `app/concepts/*/operation/`. It complements `../controller/SKILL.md` for the HTTP boundary and `references/layered-validation.md` for contract layering.

## Applies to
- when: `app/concepts/*/operation{.rb,/**/*.rb}`
- when: `app/concepts/*/contract{.rb,/**/*.rb}`
- system-review: never

## Quick Rules

Cite as `operation-pattern R<n>`. Detail and examples follow below / in references/.

R1. **One intent per Operation.** One class per domain intent (`Themes::Operation::Derive`, `Themes::Operation::Publish`, `Generations::Operation::Request`, `Generations::Operation::Complete`); no `action:`/`mode:` switching; a controller action never calls two sibling operations for one user action. → detail: RULE 1
R2. **Result contract.** `call` returns a plain payload hash on success; failures use `Failure(...)` via `inject_errors!`/`fail_with_model!`/`fail_with_code!` from `Core::Operation`. → detail: RULE 2
R3. **Failure payload shape.** Failure includes `:code` when callers route outcomes and `:model` when a form may re-render. → detail: RULE 2
R4. **No hidden dependencies.** Pass `model:`, `inputs:`, `client:` etc. explicitly; never read `params`, `session`, `ENV` or request state inside an Operation. → detail: RULE 3
R5. **Layered responsibility.** Contracts validate shape/coercion/format (an oklch triple is three numbers in range); Operations own workflow and business rules (derive, validate through `Chadcn::Theme`, repair); Models enforce persistence constraints. → detail: RULE 4
R6. **Transactions for multi-write only.** Wrap multiple writes in one transaction; never wrap a single save/update/destroy. → detail: references/transactions.md
R7. **Stable failure codes.** Controllers branch on `failure[:code]` (`:invalid`, `:contrast`, `:refused`, `:unavailable`), not model internals. → detail: RULE 6
R8. **No boundary concerns.** No rendering, redirects, flash or Turbo markup inside Operations; a broadcast is allowed only as the last step of a job-run operation. → detail: What Operations Are For
R9. **No query-only composition.** Operations do not compose read-only queries; reads belong in Query Objects. → detail: What Operations Are For
R10. **Pure math stays in services.** An operation calls `Themes::Service::Harmony` and `Chadcn::Theme`; it never carries color arithmetic itself, so the math is testable without a database. → `theme-science` R5

## What Operations Are For

Operations are the single entry point for domain writes: one intent per class, business rules and state transitions, coordination of contracts, services, models and side effects, stable result payloads the controller can route on.

Operations are NOT for query-only composition, rendering, redirects, flash, Turbo markup, or ambient state.

## RULE 1: One Operation Per Domain Intent

If one controller action represents one user intent but needs multiple mutation steps (derive, then save), compose that workflow inside one operation. Do not make the controller call two sibling operations for one click.

## RULE 2: Use the Result Contract

`Core::Operation < Dry::Operation` with `Dry::Monads[:result]` (created in `app/concepts/core/operation.rb`, the shape is in references/layered-validation.md).

```ruby
def call(model:, inputs:)
  palette = step derive(inputs)
  persisted = step persist(model, palette)
  { model: persisted, palette: palette }
end
```

```ruby
Failure(model: theme, errors: theme.errors.messages)
Failure(model: theme, errors: theme.errors.messages, code: :contrast)
Failure(code: :refused, message: "The request was declined by the model's safety system")
```

## RULE 3: No Hidden Dependencies

```ruby
# Good
Generations::Operation::Complete.new(client: Generations::Service::Client.new).call(model: generation)
```

```ruby
# Forbidden
def call
  Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"]) # constructed from ambient state inside the flow
end
```

Dependencies with a default (`client: Generations::Service::Client.new`) are declared in `initialize`, so tests inject a fake.

## RULE 4: Contracts Validate Structure, Operations Own Workflow

- Contracts: input shape, coercion, format (numbers, ranges, the allowed variable names).
- Operations: workflow and business rules (the derivation, the validation oracle, the repair pass).
- Models: persistence-time constraints.

## RULE 5: Use Transactions for Multi-Write Workflows

Patterns and examples: [references/transactions.md](references/transactions.md).

## RULE 6: Return Failure Codes the Controller Can Route On

`:invalid` (contract), `:contrast` (strict validation failed after repair), `:refused` (the model declined), `:unavailable` (API error after retries).

## Review Checklist

- One domain intent?
- All dependencies explicit in `initialize`/`call`?
- Structural validation delegated to a contract?
- Multiple writes transactional?
- Stable failure payload with the right `:code` and/or `:model`?
- Controller can route purely on success/failure?

Layering: [references/layered-validation.md](references/layered-validation.md). Transactions: [references/transactions.md](references/transactions.md).
