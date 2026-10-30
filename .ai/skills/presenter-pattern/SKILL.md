---
name: presenter-pattern
description: "Golden archetype for presenters (SimpleDelegator, `Core::Presenter::Base`) in chadcn-studio. Use when creating or editing files in `app/concepts/*/presenter/`, wrapping a theme, a generation or a preview's sample data for display, or moving display logic out of views and controllers."
---

# Golden Presenter Pattern (chadcn-studio)

## Applies to
- when: `app/concepts/*/presenter{.rb,/**/*.rb}`
- when: `app/{views,components}/**/*.rb` matching `/Presenter/`
- system-review: never

## Quick Rules

Cite as `presenter-pattern R<n>`. Detail and examples follow below / in references/.

R1. **Inherit the base.** Every presenter inherits `Core::Presenter::Base` (`app/concepts/core/presenter/base.rb`); `ApplicationPresenter` does not exist and must not be referenced. → detail: Presenter Base Class
R2. **Route helpers via `helpers`.** Use `helpers.<path>`; never `include Rails.application.routes.url_helpers` or global route helpers in a presenter. → detail: Presenter Base Class
R3. **No stuttering names.** Name classes `Editor`/`Card`/`Css` inside `Domain::Presenter`; `ThemePresenter`, `EditorPresenter`, `*_presenter.rb` are forbidden. → detail: Naming Contract
R4. **Files mirror names.** Path mirrors the class (`app/concepts/themes/presenter/editor.rb` -> `Themes::Presenter::Editor`), Zeitwerk-aligned, no legacy duplicates left. → detail: Migration Safety Checklist
R5. **Delegate, don't duplicate.** Use SimpleDelegator delegation; do not hand-write pass-through methods for the wrapped model. → detail: The SimpleDelegator Pattern
R6. **Return data, not markup.** No CSS classes or conditional HTML strings in presenters; return booleans, strings, numbers and let the view style. The one exception is an export presenter whose product IS text (`Exports::Presenter::Css` returns the theme.css text). → detail: Key Rules
R7. **Read-only.** Presenters never mutate the wrapped model or hold business logic (derivation, validation, transitions); that belongs in services and operations. → detail: Key Rules
R8. **No nesting, no per-view presenters.** Wrap related models with their own presenter; reuse one presenter across views instead of one per view. → detail: Key Rules
R9. **Context is injected.** Pass `mode:` (light/dark), the viewer's choices etc. via the initializer; never read request state inside a presenter. → detail: Key Rules
R10. **Expose `.wrap` for collections.** Collection presenters provide `.wrap` so controllers wrap lists trivially. → detail: Collections
R11. **Split base vs page presenters.** Generic display in `Card`, page-only composition in `Editor`; avoid a god presenter (200+ lines). → detail: Naming Contract
R12. **Keep public API on rename.** Preserve public methods used by views/components, or update views and tests in the same patch. → detail: Migration Safety Checklist
R13. **Preload what you read.** If a presenter reads associations, the feeding query must preload them (no N+1). → detail: Query Guardrail
R14. **No pointless presenters.** Do not add a presenter that merely renames one method or serves a one-off transformation. → detail: When to Use Presenters
R15. **Preview presenters hold sample data.** `Previews::Presenter::*` return the static fixture content of a preview page (names, numbers, rows); they take no model and own no logic beyond formatting, so a preview page is reproducible and theme-only. → `design-system` R15

## Presenter Base Class

`Core::Presenter::Base` provides SimpleDelegator wrapping, shared helpers and a `helpers` method for route helpers (shape in references/presenter-base-inheritance.md).

```ruby
class Themes::Presenter::Editor < ::Core::Presenter::Base
  def initialize(theme, mode: :light)
    super(theme)
    @mode = mode
  end

  def variables = @mode == :dark ? dark : light
  def primary = Oklch.parse(variables.fetch("primary"))
  def primary_lightness_percent = (primary.lightness * 100).round
  def export_path = helpers.theme_export_path(__getobj__, format: :css)
  def contrast_warnings = Chadcn::Theme.validate(palette)[:warnings]
end
```

## Purpose

A presenter is a lightweight wrapper around a single model (or small aggregate) that encapsulates display logic: view-agnostic, keeps the model pure, gives a clean controller-to-view boundary, reusable across render contexts.

## When to Use Presenters
- A view needs a fallback chain, a formatted value, a derived label, a path.
- The same formatting is needed by two surfaces (the editor and the card).
Not for a one-line rename of one method.

## The SimpleDelegator Pattern
The wrapped model's readers are available through delegation (`name`, `slug`, `light`, `dark`); `__getobj__` returns the model when a route helper needs it.

## Naming Contract (No Stuttering)
`Themes::Presenter::Card` (lists), `Themes::Presenter::Editor` (the editor page), `Exports::Presenter::Css`, `Exports::Presenter::Json`, `Previews::Presenter::Dashboard`. Files `card.rb`, `editor.rb`, `css.rb`.

## Key Rules
- DO return plain values; DO inject context; DO delegate.
- DO NOT mutate, DO NOT compute palettes (that is `Themes::Service::Harmony`), DO NOT read request state, DO NOT return CSS classes.

## Collections
```ruby
def self.wrap(collection, **context) = collection.map { |theme| new(theme, **context) }
```

## Query Guardrail
A presenter that reads `theme.generations` requires the feeding query to `includes(:generations)`.

## Migration Safety Checklist
1. Create the new file at the mirrored path. 2. Move methods, keep the public API. 3. Update views, components, controllers, tests. 4. Delete the old file. 5. `bin/rails test`.

## See Also
- **[phlex-view-pattern](../phlex-view-pattern/SKILL.md)** views consume presenters but do not create them.
- **[references/archetype-example.md](references/archetype-example.md)**, **[references/presenter-base-inheritance.md](references/presenter-base-inheritance.md)**.
