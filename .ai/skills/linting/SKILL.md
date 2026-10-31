---
name: linting
description: "RuboCop standards for chadcn-studio. Use when running `bin/rubocop`, fixing lint offenses, editing `.rubocop.yml`, or reviewing Ruby style (guard clauses, performance cops, Minitest clarity)."
---

# Linting (RuboCop)

## Applies to
- when: always
- levels: system
- system-review: never
- note: Loaded by name when fixing `bin/rubocop` offenses; never routed per file (RuboCop itself runs as a mechanical check).

## Quick Rules

Cite as `linting R<n>`. Detail and examples follow below.

R1. **Rubocop clean.** `bin/rubocop` passes with no offenses on the changed Ruby files (it is the first step of `bin/ci`). → detail: Suggested Workflow
R2. **Tests after lint.** Run `bin/rails test` after `bin/rubocop`, including after any `bin/rubocop -A` autocorrect. → detail: Suggested Workflow
R3. **Bang persistence.** Persistence calls follow `Rails/SaveBang` and avoid `Rails/SkipsModelValidations` violations. → detail: Focus Areas
R4. **Guard clauses.** Use guard clauses instead of deep nesting. → detail: Focus Areas
R5. **Performance and Minitest cops.** Collection/string code satisfies rubocop-performance, and tests satisfy rubocop-minitest clarity cops. → detail: Focus Areas
R6. **Style basics.** Omakase style: lines at most 120 chars, double-quoted strings, 2-space indent, snake_case methods, no trailing whitespace or commented-out code. → detail: Focus Areas
R7. **Required cops available.** `.rubocop.yml` inherits `rubocop-rails-omakase` and keeps the rails, performance, minitest, rake and capybara extensions enabled; disabling a cop is a documented decision in `.rubocop.yml`, never an inline `rubocop:disable` in app code. → detail: Dependencies
R8. **Tooling is linted too.** `.claude/scripts/**/*.rb` and `.ai/**/*.rb` are in the lint scope; the only excluded paths are generated ones (`db/schema.rb`, `vendor/`, `node_modules/`, `tmp/`). → detail: Configuration

## Dependencies
- rubocop-rails-omakase (the base configuration)
- rubocop, rubocop-rails, rubocop-performance, rubocop-minitest, rubocop-rake, rubocop-capybara (in the Gemfile's development/test group)

## Configuration
`.rubocop.yml` starts from `inherit_gem: { rubocop-rails-omakase: rubocop.yml }` and adds `require:` lines for the extensions plus the house additions (`Style/StringLiterals` double quotes is already omakase; add `Rails/SaveBang` and `Minitest/*` as enabled). Keep the file short and commented: a cop is disabled with one line saying why.

## Focus Areas
- Safe Rails patterns (`Rails/SaveBang`, `Rails/SkipsModelValidations`)
- Guard clauses to avoid deep nesting
- Performance cops for collections and string operations (the color math loops over a few dozen variables; keep it allocation-light but readable)
- Minitest cops for test clarity (`assert_predicate`, `assert_equal` argument order, no `assert true`)

## Suggested Workflow

```bash
bin/rubocop
bin/rails test
```

If style violations exist, try `bin/rubocop -A`, then rerun the tests: autocorrect can change behavior (`Style/SafeNavigation`, `Rails/SaveBang`).
