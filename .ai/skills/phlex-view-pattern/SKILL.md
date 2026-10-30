---
name: phlex-view-pattern
description: "Golden archetype for Phlex views, components, Hotwire and styling in chadcn-studio. ALWAYS load when creating or editing files in `app/views/`, `app/components/` or `app/assets/tailwind/`: dumb views, presenter extraction, sub-component decomposition, UI vs domain components, Turbo Frames/Streams targeting, stylesheet placement. Stimulus controllers have their own `stimulus` skill."
---

# Golden Phlex View Archetype (chadcn-studio)

## Applies to
- when: `app/views/**/*.rb`
- when: `app/components/**/*.rb`
- when: `app/assets/tailwind/*.css`
- companion: `accessibility` always
- companion: `design-system` when matching `/Chadcn::/`
- system-review: never
- note: `app/assets/tailwind/theme/**` belongs to `design-system` and `theme-science`; the top-level CSS glob is how "except theme/**" is expressed.

## Quick Rules

Cite as `phlex-view-pattern R<n>`. Detail and examples follow below / in references/.

R1. **Dumb views.** Display logic (fallbacks, sorting, composed strings, which variables a group shows) lives in a presenter built by the controller; views never instantiate presenters. → detail: RULE 1
R2. **Decompose big views.** Extract sub-components when helpers exceed ~50 lines; one-page-only parts live in an action folder (`index/`, `edit/`, `shared/`) with `Index::*`/`Edit::*`/`Shared::*` constants. → detail: references/sub-components.md
R3. **UI vs domain.** Generic UI is the gem (`Chadcn::*`); `app/components/` holds only domain composition (`Components::Editor::*`, `Components::Previews::*`) that forwards `**attrs`; no app-level copies of primitives. → detail: references/ui-vs-domain-components.md
R4. **Reuse shared patterns.** Use the gem's components and existing domain components; never inline an empty state, a field with errors or a toolbar that already exists. → detail: RULE 4
R5. **Safe Turbo frame targeting.** Frame ids are explicit and stable (never random/session data), empty placeholder frames sit at the top of `view_template`, and `_top` is written explicitly to break out. → detail: references/turbo-frame-targeting.md
R6. **Explicit data flow.** Views use only constructor arguments; no `request`, `params`, `session` or request-bound helpers inside views. → detail: RULE 6
R7. **Form errors visible.** Forms use `Chadcn::Field` with its error slot; raw inputs must render the model errors explicitly; overlay forms stay open on failure. → detail: references/ui-vs-domain-components.md
R8. **Base classes and files.** Views inherit `Views::Base`, components `Components::Base`; snake_case files; English copy as literals in the view (no locale files in v1). → detail: File Conventions
R9. **Semantic tokens only.** Use design-system tokens in Tailwind classes; no hardcoded palette classes or color literals. → `design-system` R1
R10. **Compound helpers.** Multi-part components are called through the root's helpers (`card.header`) or the explicit nested classes, consistently inside one view; Stimulus defaults live in domain components, not repeated in views. → detail: references/frontend-overview.md
R11. **Stimulus naming.** Controllers mirror view ownership in their path (`editor/preview_controller.js`) and use the matching identifier (`editor--preview`) in `data-controller`/`data-action`. → `stimulus` R10
R12. **Overlay stacking.** Never place Sheet/Dialog `content` inside a stacking-context container (`sticky`/`relative`+z-index, transform, filter, will-change); overlays use fixed positioning. → detail: references/frontend-overview.md
R13. **Links use route helpers.** Never write a raw `a(href: ...)` with a hand-built path string; use `link_to`/route helpers or a presenter path. → detail: references/frontend-overview.md
R14. **Domain-based frames.** Frame decomposition follows domain concepts (`theme_export`, `generation_status`), not atomic UI pieces (`card_section`, `button_group`). → detail: references/turbo-frames.md
R15. **Stylesheet placement.** `app/assets/tailwind/application.css` is an import manifest (the gem's managed block plus `theme/theme.css`); any extra CSS goes in `app/assets/tailwind/{foundation,components,domains}/` imported explicitly, never colors. → detail: references/stylesheet-organization.md
R16. **Split divergent form intents.** Editing a group of variables and requesting a generation are separate components, not one mode-switched form. → detail: references/ui-vs-domain-components.md
R17. **Preview pages inside the preview root only.** `Views::Previews::*` render only inside `Components::Editor::PreviewRoot`; nothing of the editor chrome is rendered inside it and no preview block is rendered outside it, so the runtime variables apply to exactly the preview. → `design-system` R12

**Load this skill FIRST for any work in `app/views/` or `app/components/`.**

---

## What Views Are For

Phlex views are strictly for **emitting HTML and assembling UI components**. They map structured data to visual elements using Tailwind classes and the gem's components.

Views are **NOT** for:

| Concern | Correct Layer |
|---|---|
| Database queries or N+1 lookups | Query Objects → passed in by controller |
| Display logic, fallback chains, format transforms (an oklch value as "62% light") | Presenters (`app/concepts/*/presenter/`) |
| Direct record mutation | Operations (`app/concepts/*/operation/`) |
| Color math | `Themes::Service::Harmony`, never a view |

---

## RULE 1 — Extract Display Logic to Presenters

```ruby
# app/concepts/themes/presenter/editor.rb
class Themes::Presenter::Editor < Core::Presenter::Base
  def primary_lightness_percent = (primary.lightness * 100).round
  def contrast_warnings = validation.errors.select { |error| error.include?("contrast") }
end

# In the Phlex view
span { "#{@presenter.primary_lightness_percent}%" }
```

**Data flow rule:** controllers initialize the presenter and pass it to the view (`@presenter = Themes::Presenter::Editor.new(theme)`). Views never instantiate presenters themselves.

> **Sub-Component Decomposition:** directory convention, action-based nesting → [references/sub-components.md](references/sub-components.md)

## RULE 3 — Strict UI vs. Domain Component Separation

Generic UI is the gem. `app/views/` = pages; `app/components/editor/` = the editor chrome (sidebar groups, pickers, export panel); `app/components/previews/` = the blocks preview pages are made of; `app/components/shared/` = cross-domain helpers. Never put domain logic in a component that could live in the gem. Form errors must always be visible. Details: [references/ui-vs-domain-components.md](references/ui-vs-domain-components.md).

## RULE 4 — Reuse Shared UI Patterns (No Reinvention)

Reach for the gem's component (`Chadcn::Empty`, `Chadcn::Field`, `Chadcn::ButtonGroup`...) or an existing domain component; extract a shared view class if a pattern repeats.

> **Safe Turbo Frame Targeting:** frame ids, full-page navigation from inside frames → [references/turbo-frame-targeting.md](references/turbo-frame-targeting.md)

## RULE 6 — Explicit Data Flow (No Ambient State in Views)

Views receive **only** what is passed via `initialize`. They must not reach into `request`, `params`, `session` or ActionView helpers that access HTTP request context.

## File Conventions

| Convention | Detail |
|---|---|
| Base class (views) | `Views::Base` |
| Base class (components) | `Components::Base` |
| Sub-component location | Same directory as the parent view |
| File naming | `snake_case.rb` |
| Class naming | `CamelCase` inside the correct module namespace |
| Copy | English literals in the view; no `t(...)`, no locale files (v1) |
| Tailwind classes | Semantic design-system tokens only |

## Workflow

1. Decide the **layer**: page view (`app/views/`), editor component (`app/components/editor/`), preview block (`app/components/previews/`).
2. If the view needs formatted or derived data → create or extend a **Presenter** first.
3. Implement `view_template`. If private helpers grow beyond ~50 lines, extract sub-components.
4. Apply Tailwind via semantic design-system tokens.
5. Verify Turbo Frame IDs are stable; use `_top` for full-page transitions.
6. Load companion skills for adjacent concerns.

## Companion Skills

- **[../design-system/SKILL.md](../design-system/SKILL.md)** the gem's components, the preview root and the gallery.
- **[references/frontend-overview.md](references/frontend-overview.md)** compound component wiring, Hotwire integration.
- **[references/stylesheet-organization.md](references/stylesheet-organization.md)** stylesheet placement beyond Tailwind utilities.
- **[references/turbo-frames.md](references/turbo-frames.md)** frame decomposition strategies.
- **[../query-object-pattern/SKILL.md](../query-object-pattern/SKILL.md)** when a view feels like it needs to query data directly.
- **[references/frontend/views.md](references/frontend/views.md)**, **[references/frontend/components.md](references/frontend/components.md)**, **[references/frontend/form-snapshot.md](references/frontend/form-snapshot.md)** worked shapes.

Some reference examples predate the English-only decision and still call `t(...)`; in this app write the English literal.
