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
`accessibility`. Everywhere: `naming-conventions`, `linting`, `testing`. Every skill opens with an `## Applies to` block that routes
files to it (the workflow plugin reads it). Long material sits in each skill's `references/`; implementation notes belong there, not
in the repo root.

## Workflow: the `flow` plugin (`papiroflexia`)

The plan/build/gates/audit/review workflow is not in this repository: it is the `flow` plugin from the `papiroflexia`
marketplace (one source shared by papyro, chadcn and chadcn-studio). This repo only parametrizes it:
`.claude/workflow.yml` (stack facts, workspace repos, audit tracks, gate commands, mechanical checks, board settings; validate
with `"${CLAUDE_PLUGIN_ROOT}/bin/flow" manifest check`), the `## Applies to` block at the top of every skill (which files a
skill governs; `"${CLAUDE_PLUGIN_ROOT}/bin/flow" skill_router check` must print `ROUTER: OK`), and the gate permissions in
`.claude/settings.json`. Workflow rules (claims, stages, merge policy): the plugin's `flow` skill.

- Board (GitHub issues of this repository): `/flow:epic-plan <goal>` creates the items; `/flow:work --epic <slug>` is the worker loop
  (claim, worktree, stages, audit, PR; never merges); `/flow:merge --epic <slug>` is the human-run release manager, the only command
  that merges; `/flow:status`, `/flow:release`.
- `/flow:plan-feature <item> [--epic …] [--dry-run]`: Top-Down blueprint and greenfield scaffolds; writes `docs/features/<slug>/ARCHITECTURE.md`.
- `/flow:audit-feature [range] [--fix]`: Map-Reduce audit (Bricks -> Rooms/Stimulus -> Slices -> House) of the diff; the manifest's
  `palette_leaks` check flags hardcoded colors outside the theme file; `--fix` runs the Actor-Critic loop. Output in `tmp/audit/<slug>/`.
  `/flow:audit-golden` is its regression test against this repo's skills (seeds in `.claude/golden/audit/cases/`); run it after
  editing Quick Rules or an `Applies to` block. `"${CLAUDE_PLUGIN_ROOT}/bin/flow" audit_rule_coverage` reports rules never cited.
- Agents ship with the plugin: `flow:feature-blueprint-planner`, `flow:senior-rails-dev` (the builder), `flow:brick-method-auditor`,
  `flow:room-class-auditor`, `flow:stimulus-controller-auditor`, `flow:view-slice-auditor`, `flow:principal-architect`.
- Merging to `main` is a human step.
