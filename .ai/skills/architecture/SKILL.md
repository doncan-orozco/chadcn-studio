---
name: architecture
description: "chadcn-studio app architecture: where code lives (`app/concepts/*/{operation,contract,query,presenter,service}`), vertical-slice and no-namespace-stuttering rules, the theme/generation/preview domains, and the split between Ruby (derivation, validation, export) and Stimulus (instant preview). Use when deciding where new code belongs, adding a page, component, preview or concept, or organizing files across layers."
---

# Architecture (Clean Architecture + dry-rb)

chadcn-studio is a single Rails 8.1 app (Ruby 4.0, SQLite with the Solid stack, Phlex views, Hotwire, Tailwind 4) whose design system is the `chadcn` gem. The product is a theme builder: preview pages rendered with the real `Chadcn::*` components, sidebar groups that edit theme variables, a harmony rule that derives a full shadcn theme from a few inputs, an LLM generation step, and exports in the gem's own theme format. The domain knowledge lives in `theme-science` and `llm-generation`; this skill says where code goes.

## Quick Rules

Cite as `architecture R<n>`. Detail and examples follow below / in references/.

R1. **Concepts vertical slice.** Domain backend code lives in `app/concepts/{domain}/{operation,contract,query,service,validator,presenter}/`, not in horizontal top-level folders. Domains of this app: `themes` (saved themes and their palettes), `generations` (LLM runs), `previews` (the preview pages' view models), `exports` (CSS, JSON, URL), `core` (the base classes). → detail: Vertical Slice Rule
R2. **Namespaced classes.** Classes use `Domain::Layer::Name` (e.g. `Themes::Query::Recent`) with file paths matching module nesting for Zeitwerk. → detail: Vertical Slice Rule
R3. **No namespace stuttering.** Class and file names never repeat the domain or layer (`Recent`, not `RecentQuery`; `Palette`, not `PaletteValidator`). → detail: No Namespace Stuttering
R4. **Thin controllers.** Controllers only parse params, call one namespaced concept object and render; no domain logic in them. → detail: references/controllers.md
R5. **Models persist only.** `app/models/` holds persistence concerns; reads go to query objects and writes to operations. → detail: references/models.md
R6. **Write flow order.** Mutations go contract, then operation (business rules and persist), returning a payload or `Failure(model: ...)`. → detail: Operations Flow
R7. **Operation `call` returns plain payload.** `call` returns a plain hash (e.g. `{ model: theme }`), never an explicit `Success(...)`. → detail: references/operations.md
R8. **Contracts structural only.** Contracts check types, coercion and key presence; uniqueness, state and persisted-format rules live in models. → detail: references/contracts.md
R9. **One operation per intent.** Each intent gets one operation (`Themes::Operation::Derive`, `Generations::Operation::Request`, `Exports::Operation::Publish`), with no `action` flag branching and controller actions mapping 1-to-1. → detail: references/operations.md
R10. **Update flows.** Update contracts accept partial payloads and assign only validated keys. → detail: references/operations.md
R11. **Consistent failure payload.** Failures return `{ model:, errors: }` (plus `:code` when the caller routes on it) with contract errors injected into an ActiveModel instance. → detail: references/operations.md
R12. **Refactor cleanup.** Structural moves delete legacy duplicate files, update all call sites, and keep path, module and class names aligned. → detail: Refactor Safety Checklist
R13. **Ruby owns the theme, JavaScript owns the preview.** Derivation, validation (through `Chadcn::Theme`) and export are Ruby in `app/concepts`; the browser only sets CSS variables on the preview root for instant feedback and posts the inputs back. No color math duplicated in two places. → `theme-science`
R14. **The gem is upstream.** `Chadcn::*` components and the `chadcn--*` controllers are never patched here; a component defect is fixed in doncan-orozco/chadcn and the lock bumped. → `design-system` R14
R15. **Core base classes.** `Core::Operation` (dry-operation + dry-monads result helpers), `Core::Presenter::Base` (SimpleDelegator + `helpers`) and `ApplicationQuery` are the only base classes; they live in `app/concepts/core/` and `app/queries/application_query.rb` and are tested like any concept. → `operation-pattern`, `presenter-pattern`, `query-object-pattern`

## Dependencies
- dry-operation
- dry-monads
- dry-validation

## File Structure
```
app/
  concepts/
    core/
      operation.rb              # Core::Operation
      presenter/base.rb         # Core::Presenter::Base
    themes/
      operation/
        create.rb               # save a theme from the editor inputs
        derive.rb               # inputs -> full palette (the harmony rule)
      contract/
        create.rb
      query/
        recent.rb
      presenter/
        editor.rb               # what the editor page shows
      service/
        harmony.rb              # pure color math, no persistence
    generations/
      operation/request.rb      # prompt -> job -> palette inputs
      service/client.rb         # the Anthropic call (see llm-generation)
    exports/
      operation/publish.rb      # theme -> stable URL
      presenter/css.rb          # theme -> theme.css text
    previews/
      presenter/dashboard.rb    # fixture data for a preview page
  components/                   # Phlex: editor chrome, preview blocks (Components::*)
    editor/
    previews/
  views/                        # Phlex pages (Views::*)
    themes/
    previews/
  controllers/                  # thin
  models/                       # Theme, Generation (persistence only)
  jobs/                         # GenerateThemeJob (thin; Solid Queue)
  javascript/controllers/       # editor--* Stimulus controllers (preview, pickers)
```

### Vertical Slice Rule

For domain-specific backend code, prefer `app/concepts/{domain}/...` over horizontal top-level folders.

#### No Namespace Stuttering
**Do not repeat the domain or type in the class or file name.**

**Correct:**
- `app/concepts/themes/query/recent.rb` → `Themes::Query::Recent`
- `app/concepts/themes/service/harmony.rb` → `Themes::Service::Harmony`
- `app/concepts/themes/presenter/editor.rb` → `Themes::Presenter::Editor`

**Incorrect:**
- `recent_query.rb`, `harmony_service.rb`, `theme_presenter.rb`

1. Put read flows in `app/concepts/{domain}/query/` using `Domain::Query::*` namespaces.
2. Put pure domain computations (color math, export rendering) in `app/concepts/{domain}/service/`.
3. Put domain validators in `app/concepts/{domain}/validator/`.
4. Put domain presenters in `app/concepts/{domain}/presenter/`.
5. Keep controllers thin and call these namespaced objects directly.

### Refactor Safety Checklist (Required)

1. Remove legacy duplicate files immediately after references are migrated.
2. Verify file path, module nesting, and class name alignment for Zeitwerk.
3. Confirm all call sites are updated (controllers, views, operations, tests).
4. Run targeted suites for touched domains before full test runs.
5. Finish with `bin/ci`.

## Operations Flow (typical)
1. Validate and sanitize with a dry-validation contract
2. Build the model and enforce business rules in the operation
3. Persist and rely on ActiveRecord state validations
4. Return a payload hash or `Failure(model: ...)` for form rerender paths

## Reference Map

- **[references/architecture-overview.md](references/architecture-overview.md)** layer responsibilities and composition.
- **[references/operations.md](references/operations.md)** write flows with `Core::Operation` and `Dry::Monads`.
- **[references/contracts.md](references/contracts.md)** dry-validation contract structure.
- **[references/controllers.md](references/controllers.md)** thin controller patterns.
- **[references/queries.md](references/queries.md)** query-object structure and read-model boundaries.
- **[references/services.md](references/services.md)** focused domain service patterns.
- **[references/jobs.md](references/jobs.md)** background job orchestration around operations.
- **[references/models.md](references/models.md)** persistence-only model guidance.

For the canonical mutation shape load `operation-pattern`; for anything in `app/views/` or `app/components/` load `phlex-view-pattern` first; for the theme variables, the harmony rule and the exports load `theme-science`.
