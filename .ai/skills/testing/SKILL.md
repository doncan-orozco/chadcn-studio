---
name: testing
description: "Minitest testing for chadcn-studio, including system tests. Use when writing or fixing anything under `test/` (operations, contracts, queries, presenters, services, components, controllers, jobs, Capybara/Cuprite system tests for the editor and the previews) or running the CI pipeline (`bin/ci`)."
---

# Testing (Minitest + dry-rb)

## Quick Rules

Cite as `testing R<n>`. Detail and examples follow below / in references/.

R1. **Mirror concept tests.** Every new file under `app/concepts/**/{operation,query,presenter,service}/` has a matching `test/concepts/**/<same layer>/*_test.rb`. → detail: Concept Coverage Policy
R2. **Core abstractions tested.** Changes to `app/concepts/core/` come with lightweight contract tests locking base behavior. → detail: Concept Coverage Policy
R3. **Success plus failure.** Each concept test file asserts at least one success path and one failure/edge path (where applicable). → detail: Concept Coverage Policy
R4. **Payload shape asserted.** Operation and query tests check the result payload shape, not just success/failure. → detail: Concept Coverage Policy
R5. **Fixtures by default.** Test data comes from fixtures (`test/fixtures/themes.yml` carries at least the zinc preset as a saved theme); FactoryBot is added only when fixtures become unmanageable. → detail: Suggestions
R6. **Semantic component assertions.** Component and view tests assert key sections, variants and data attributes, without snapshots or brittle class-level checks. → detail: UI Components (Phlex) / Views
R7. **Color math is table-driven.** `Themes::Service::Harmony` and the export presenters are tested with small tables of inputs and expected variables (within a tolerance for floats), including the dark mode branch and the contrast repair; the oracle for "valid" is `Chadcn::Theme.validate`, never a hand-written checker. → detail: Theme tests
R8. **No network in tests.** The Anthropic client is stubbed at the `Generations::Service::Client` boundary (a fake returning a fixed palette input or raising a typed error); no test sends a request, and `ANTHROPIC_API_KEY` is never required to run the suite. → `llm-generation` R9
R9. **No sleep in system tests.** System tests never call `sleep`; they wait via `assert_text`, `assert_selector` or `assert_current_path`. → detail: references/hotwire-system-testing.md
R10. **UI before database.** After a Turbo/Stimulus action, assert a visible UI signal before asserting persisted state. → detail: references/hotwire-system-testing.md
R11. **Selector order and `:testid`.** Use labels/button text first; `data-testid` only for async or unstable elements, queried via `find(:testid, ...)`, never raw `[data-testid=...]` CSS or nth-child selectors. → detail: references/hotwire-system-testing.md
R12. **Thin system tests.** System tests set up state in Ruby, cover one visible UI error path, and leave validation matrices to contract/operation tests. → detail: references/hotwire-system-testing.md
R13. **Preview variables asserted in the browser.** The system test of the editor moves one control and asserts the computed style of the preview root (`evaluate_script` on `getPropertyValue("--primary")`), which is the only way to prove the Stimulus contract. → detail: Theme tests
R14. **Green CI pipeline.** New code has tests, no undocumented skipped tests, and `bin/ci` (rubocop, bundler-audit, importmap audit, brakeman, `bin/rails test`, seeds) passes before push; `bin/rails test:system` runs when a system test changed. → detail: references/ci-verification.md

## Dependencies
- minitest, capybara, cuprite
- dry-monads, dry-validation

## Concept Coverage Policy (Required)

1. Every file under `app/concepts/**/operation/*.rb` must have a corresponding test under `test/concepts/**/operation/*_test.rb`.
2. Every file under `app/concepts/**/query/*.rb` must have a corresponding test under `test/concepts/**/query/*_test.rb`.
3. Every file under `app/concepts/**/presenter/*.rb` must have a corresponding test under `test/concepts/**/presenter/*_test.rb`.
4. Every file under `app/concepts/**/service/*.rb` must have a corresponding test under `test/concepts/**/service/*_test.rb`.
5. Core abstractions under `app/concepts/core/` must have lightweight contract tests to lock base behavior.

Minimum expectation per concept test file: one success-path assertion, one failure/edge-path assertion (where applicable), payload shape checks for operation/query contracts.

## Theme tests

- `Themes::Service::Harmony`: a table of `{ primary: Oklch, expected: { "--primary" => ..., "--ring" => ... } }` rows for light and dark; assert with `assert_in_delta` on the parsed numbers, not on strings, so formatting changes do not break them.
- Every derived palette passes `Chadcn::Theme.validate(palette, strict: true)` in a test; this is the single oracle for completeness, format and contrast.
- Exports: the CSS presenter's output round-trips through `Chadcn::Theme.parse` and equals the palette it was rendered from; the markers `theme:colors:start`/`end` are present exactly once each.
- Generation: the operation is tested with a fake client for the three outcomes (valid palette, invalid palette repaired, refusal/API error surfaced as a failure code).

## Suggestions
- Framework: Minitest (Rails-native, fast, minimal)
- Test data: fixtures by default
- System tests: Capybara with Cuprite (headless Chrome); `test/application_system_test_case.rb` registers the driver

## UI Components (Phlex)
- Render components and assert HTML output.
- Verify variant/size classes and data attributes (the preview blocks must carry the `editor--preview` wiring).
- Keep assertions semantic (avoid brittle class-level expectations when possible).

## Views
- Treat views as integration units: render and assert key sections.
- Avoid snapshot noise; assert only critical content.

## Test Organization

```
test/
  application_system_test_case.rb
  test_helper.rb
  concepts/
    themes/
      operation/derive_test.rb
      service/harmony_test.rb
    generations/
      operation/request_test.rb
  controllers/
    themes_controller_test.rb
  components/
    previews/dashboard_test.rb
  jobs/
    generate_theme_job_test.rb
  system/
    editor/
      edit_primary_color_test.rb
      export_theme_test.rb
  fixtures/
    themes.yml
  support/
    fake_generation_client.rb
```

## Coverage Checklist

- [ ] Operations: happy path + all failure cases
- [ ] Contracts: all validation rules
- [ ] Harmony and exports: table-driven, validated by `Chadcn::Theme`
- [ ] Components: rendering + variants
- [ ] System tests: critical user flows (edit a color, switch dark mode, export)
- [ ] Generation: fake client, three outcomes
- [ ] Accessibility: keyboard navigation, ARIA labels

> **CI/CD Verification Pipeline:** what CI checks, local pre-push, troubleshooting → [references/ci-verification.md](references/ci-verification.md)
> **Hotwire system tests:** [references/hotwire-system-testing.md](references/hotwire-system-testing.md), examples in [references/hotwire-system-tests-examples.md](references/hotwire-system-tests-examples.md), concept test examples in [references/tests.md](references/tests.md).
