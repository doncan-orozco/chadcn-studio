# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

chadcn-studio is a theme builder for the chadcn design system (shadcn/ui ported to Phlex, gem `doncan-orozco/chadcn`): a Rails 8.1 /
Ruby 4.0 app (SQLite with the Solid stack, Phlex views, Hotwire, Tailwind 4) where a user picks a primary color, the app derives a whole
shadcn theme by a harmony rule, previews it on real pages (dashboard, form, landing, settings, auth) rendered with the gem's own components,
tunes variables by group, or asks Claude for a theme from a prompt, and exports the result as a shadcn-format `theme.css`, a JSON file or
an https URL that `bin/rails chadcn:theme:import[url]` consumes. One repository, no engine.

The Gemfile takes chadcn from GitHub; `.bundle/config` (`BUNDLE_LOCAL__CHADCN`) points Bundler at the sibling checkout `../chadcn`, so
gem edits are live here. Gem changes are made and released there, not here.

## Commands

```bash
bin/setup                       # install deps, prepare DB
bin/dev                         # server + tailwindcss:watch (Procfile.dev)
bin/ci                          # the Gate: rubocop, bundler-audit, importmap audit, brakeman, rails test, seeds (config/ci.rb)
bin/rubocop                     # omakase + rails/performance/minitest/rake/capybara
bin/rails test                  # Minitest; bin/rails test test/path_test.rb:LINE for one
bin/rails test:system           # Capybara + Cuprite
bundle exec rake test:tooling   # tests of the repository tooling in .claude/scripts (never boots Rails)
bin/rails chadcn:doctor         # the gem's integration checks
bin/rails theme:list|use[x]|import[src]|check   # the gem's theme tasks on app/assets/tailwind/theme/theme.css
```

Run them with `env -u BUNDLE_GEMFILE` and a UTF-8 locale (`LANG=en_US.UTF-8`) if your shell exports something else.

## Architecture

- **Mutations go through operations**, not controllers or models: `app/concepts/<domain>/{operation,contract,query,presenter,service}`
  with dry-operation / dry-monads / dry-validation. `call` returns a payload hash, takes explicit deps (`model:`, `inputs:`, `client:`),
  never reads `Current`, `params` or `ENV`. Controllers only dispatch, branch on the result and render.
- **Color math is one place.** `Themes::Service::Harmony` derives the palette in oklch (skill `theme-science`); `Chadcn::Theme` validates
  it (format, completeness, contrast); nothing else validates. JavaScript owns only the instant preview: a Stimulus controller sets CSS
  variables on the preview root and toggles `.dark`.
- **Views are Phlex** (`app/views` with `Views::Base`, `app/components` with `Components::Base`). Generic UI is `Chadcn::*`; the app holds
  only domain composition (editor, preview pages, gallery from `Chadcn::Catalog`). Semantic tokens only, no palette classes or color literals.
- **LLM generation** is one structured call to `claude-opus-5-5` through the `anthropic` gem, behind an operation and a Solid Queue job,
  delivered by Turbo Stream, validated by `Chadcn::Theme` before it touches anything (skill `llm-generation`). Tests stub the client.
- **No auth, no i18n, no mailers in v1.** English literals in views.

## Conventions live in `.ai/skills/` (exposed through the `.claude/skills` symlink)

Read the relevant SKILL.md before working in an area; every skill starts with numbered Quick Rules that audits cite as `<skill> R<n>`.
Domain: `theme-science`, `llm-generation`, `design-system`. Layers: `architecture`, `controller`, `operation-pattern`,
`query-object-pattern`, `presenter-pattern`, `models`, `jobs-and-mailers`, `sqlite`. Front end: `phlex-view-pattern`, `stimulus`,
`accessibility`. Everywhere: `naming-conventions`, `linting`, `testing`. Process: `epic-flow`. Long material sits in each skill's
`references/`; implementation notes belong there, not in the repo root.

## Commands and agents (`.claude/`)

- Epic flow (GitHub issues of this repository as the board, `.claude/scripts/epic/work_board.rb`): `/epic-plan <goal>` creates the items;
  `/work --epic <slug>` is the worker loop (claim, worktree, stages, audit, PR; never merges); `/work-merge --epic <slug>` is the human-run
  release manager, the only command that merges; `/work-status`, `/work-release`.
- `/plan-feature <item> [--epic …] [--dry-run]`: Top-Down blueprint and greenfield scaffolds; writes `docs/features/<slug>/ARCHITECTURE.md`.
- `/audit-feature [range] [--fix]`: Map-Reduce audit (Bricks -> Rooms/Stimulus -> Slices -> House) of the diff; `--fix` runs the
  Actor-Critic loop (max 3 iterations). Output in `tmp/audit/<slug>/`. `/audit-golden` is its regression test (seeds in
  `.claude/audit-golden/`); run it after editing agent prompts or Quick Rules. `ruby .claude/scripts/audit_rule_coverage.rb` reports
  rules never cited.
- Agents in `.claude/agents/`: `feature-blueprint-planner`, `senior-rails-dev` (the builder), `brick-method-auditor`, `room-class-auditor`,
  `stimulus-controller-auditor`, `view-slice-auditor`, `principal-architect`.
- Merging to `main` is a human step. The epic flow, commands and agents are copies of the ones in chadcn and papyro; keep them in step
  until they are extracted into a shared plugin.
