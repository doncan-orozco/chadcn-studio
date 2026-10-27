---
description: Top-Down feature planning (City -> House -> Rooms -> Bricks) with greenfield scaffolding for chadcn-studio (Rails 8 + Phlex + Stimulus on the chadcn gem).
argument-hint: "<ticket text or @ticket.md> [--epic <text|@file>] [--dry-run]"
allowed-tools: Agent, Read, Grep, Glob, TodoWrite, Bash(git:*)
---

# Top-Down Feature Planning: City, House, Rooms, Bricks

Target: $ARGUMENTS
If $ARGUMENTS is empty, ask for the ticket text (and epic text if one exists).

Input convention — parse $ARGUMENTS as: `[ticket...] [--epic <text|@file>] [--dry-run]`
- `ticket...` (required): raw ticket text with acceptance criteria, or `@path/to/ticket.md` (`Read` it first; never truncate intent). An epic item of the board (`/work`) is passed as its issue body.
- `--epic <text|@file>`: parent epic context (City). Optional but recommended; without it you derive a minimal City Map from the codebase and say so.
- `--dry-run`: output blueprint + file list only, write no files.
- No issue-tracker API is wired in. You are the orchestrator (main session); `Agent` fan-out is the pipeline.

You are the orchestrator. You DO NOT write business logic. You produce a City-aware blueprint, then fan out greenfield scaffolding to the Builder. Planning is Top-Down, the exact inverse of `/audit-feature`: Epic (City) → Ticket (House) → Files (Rooms) → Methods (Bricks, left as TODOs).

Stack facts: Ruby 4.0 / Rails 8.1 / SQLite (Solid Queue/Cache/Cable), Phlex views + components (`Views::Base`, `Components::Base`), Turbo + Stimulus (importmap), Tailwind 4, the chadcn gem as the design system (`Chadcn::*`, `chadcn--*` controllers, theme in `app/assets/tailwind/theme/theme.css`), dry-operation/dry-monads/dry-validation under `app/concepts/<domain>/{operation,contract,query,presenter}`, the `anthropic` gem for LLM theme generation, Minitest + Capybara/Cuprite. One repository, no authentication and no i18n in v1 (English strings are plain literals in views).

## Phase 0 — City Map (you do this)
1. `REPO` = `git rev-parse --show-toplevel`. Build the City Map from the pasted `--epic` text (ubiquitous language, boundaries) and codebase reality via `Grep`/`Glob`/`Read`: `db/schema.rb`, `app/models`, `app/concepts/*/{operation,contract,query,presenter}`, `app/controllers` + `config/routes.rb`, `app/views`, `app/components`, `app/javascript/controllers`, `app/jobs`, `app/assets/tailwind/theme`, and the gem's surface the feature leans on (`Chadcn::Catalog`, `Chadcn::Theme`, the components the preview pages compose). Record only what exists — never invent infrastructure.
2. Output a compact City Map: `domain`, `existing_infrastructure`, `ubiquitous_language` (3–10 terms: theme, palette, token, preset, preview page, harmony rule, export …). No epic ⇒ mark `DERIVED_FROM_CODE` and keep it minimal.

## Skill Catalog & Layer Map (Phases 1–2; the same law the audit enforces)
Skills live in `<REPO>/.ai/skills/<name>/SKILL.md`.

| Layer / path | Holds | Skills to bind | Returns |
|---|---|---|---|
| `app/controllers/**`, `config/routes.rb` | HTTP boundary: parse, dispatch, render. Strict REST; transitions are sub-resource controllers | `controller`, `naming-conventions` | redirect/render |
| `app/concepts/*/operation/**` | one write intent per operation, explicit deps, transactions for multi-write | `operation-pattern`, `naming-conventions` | payload hash / failure with `code` |
| `app/concepts/*/contract/**` | structural validation (dry-validation) | `operation-pattern` (layered validation) | contract result |
| `app/concepts/*/query/**` | reads, filtering, sorting (unpaginated Relation) | `query-object-pattern` | `ActiveRecord::Relation` |
| `app/concepts/*/presenter/**` | display logic (SimpleDelegator over `Core::Presenter::Base`) | `presenter-pattern` | display values |
| `app/concepts/themes/**` color code (derivation, validation, export) | the harmony rule, oklch math, the shadcn variable set, `Chadcn::Theme` validation, export formats | `theme-science`, `operation-pattern` | palette / CSS |
| LLM generation (operation + job + client) | one structured call, schema-parsed, validated before use | `llm-generation`, `jobs-and-mailers` | validated palette |
| `app/models/**`, validators | schema, associations, simple validations, state predicates; no scopes, no business logic | `models` | — |
| `app/views/**`, `app/components/**` | dumb Phlex views, sub-components, preview pages composed from `Chadcn::*` | `phlex-view-pattern`, `accessibility`, `design-system` | HTML |
| `app/javascript/controllers/**` | Stimulus behavior (declared targets/values, cleanup in `disconnect`; the live preview sets CSS variables) | `stimulus`, `accessibility` | — |
| `app/jobs/**`, `app/mailers/**`, `app/services/**` | thin job shells, external clients | `jobs-and-mailers`, `operation-pattern` | — |
| `db/migrate/**` | safe migrations (strong_migrations) | `sqlite` | — |
| `test/**` | Minitest per concept; system tests for Hotwire flows | `testing` | — |

Placement test for ANY new Ruby file: changes state ⇒ operation (+ contract); finds records ⇒ query; formats for display ⇒ presenter (never in the view or controller); derives, validates or exports colors ⇒ the theme concept (`theme-science`), never a view or a Stimulus controller alone (JS mirrors the rule for the live preview, Ruby is the truth); calls the LLM ⇒ an operation behind a job with an injected client; shows HTML ⇒ Phlex view/component; reacts to the browser ⇒ Stimulus; queue entry ⇒ thin job + operation. Controllers get no logic, models get no scopes.

## Phase 1 — House Blueprint (one planner call)
1. Send ONE `feature-blueprint-planner` call with `EPIC_CONTEXT + TICKET (verbatim) + CODEBASE_EXCERPTS (routes, schema, related files, trimmed)`. Demand strict JSON `ticket, city_notes, house_blueprint[]`, each entry `action, file_path, skills_to_apply, responsibility, contract, acceptance_trace`.
2. Validate yourself: every entry traces to an AC bullet; every `create` justifies why no City entry sufficed; placement follows the Layer Map; each mutation has ONE operation per intent (no action-flag operations, no controller-side orchestration of several operations); each new controller action is one of the 7 REST actions or a sub-resource controller; every controller entry names the operation/query it calls; every view entry names its presenter and uses no logic; every preview page entry lists the components it composes and exercises only theme tokens; every model change binds `models` (no scopes, no callbacks orchestrating writes); every migration binds `sqlite` and is strong_migrations-safe; every Stimulus entry lists its targets/values and the view that uses it; every theme-derivation or export entry binds `theme-science` and names the validation step; every LLM entry binds `llm-generation` and names its schema and the validation that gates it; every new file has a test entry mirroring its path under `test/`. Invalid ⇒ retry ONCE naming the defect; still bad ⇒ stop and show the defect to the user. Never scaffold from a broken blueprint.

## Phase 2 — Greenfield Scaffold (parallel per file)
Resolve each entry's `skills_to_apply` (+ path-matched skills from the audit's Phase 0.5 matrix) to ABSOLUTE `SKILL.md` paths, `Glob` to verify, and pass them as `<SKILL_FILES>` (paths only, max 5 per file); the Builder `Read`s them in full first.
1. ONE `senior-rails-dev` call PER blueprint file, all in the SAME block, prompt = `Scaffold greenfield skeleton ONLY. No business logic — TODO blocks. <SKILL_FILES> + file_path + responsibility + contract + acceptance_trace. Rules: operations inherit the project's operation base, take explicit dependencies, return the documented payload/failure-code shape, one public \`call\`; contracts validate structure only; queries return an unpaginated Relation; presenters inherit \`Core::Presenter::Base\`; controllers hold only dispatch → render/redirect with \`status: :unprocessable_entity\` on invalid models; views are Phlex, dumb, read only the presenter, no fetch or queries, compose \`Chadcn::*\` and use theme tokens only; Stimulus controllers declare targets/values and clean up in disconnect; migrations safe for strong_migrations; a Minitest test file created alongside each Ruby file. Minimal diff, no global formatters.`
2. The Builder writes files + tests + TODOs and returns `git status` of created files. The blueprint is frozen during scaffolding. If a Builder reports a blueprint contradiction, stop that file, surface it, continue the rest.

## Phase 3 — Handoff (you do this)
1. Write `ARCHITECTURE.md` in the branch (one `senior-rails-dev` file-write call, or inline on `--dry-run`): City Map summary, blueprint table (file → action → skill → AC trace), contracts, the developer TODO list, the branch name, and the verify command `/audit-feature <branch> [--fix]`. Implementation docs do NOT belong in the repo root: write to `docs/features/<ticket-slug>/ARCHITECTURE.md`.
2. Publish the blueprint table + TODOs verbatim and state `scaffolded_files: N, logic_todos: M, audit_command: /audit-feature <branch>`.
3. Close todos. The developer fills the TODOs, opens a PR, and the audit verifies the boundaries planning established.

## Rules
- Top-Down only: never audit here, never write logic in scaffolds (TODOs only).
- One session throughout (planner JSON and skill bodies stay prompt-cached).
- Cost: planner is one heavy call (`opus`); scaffolds are parallel Builder calls (`sonnet`). Cap blueprints at 15 files; larger epics split per ticket.
- Never commit or push. Output files + diff stat only.
