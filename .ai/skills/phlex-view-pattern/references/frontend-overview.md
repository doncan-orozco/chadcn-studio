# Frontend Overview (Hotwire, Phlex, Tailwind)

> Merged from the former `frontend` skill.

# Frontend (Hotwire + Phlex + Tailwind)

Use this skill for application-facing frontend work. Keep the SKILL body focused on the rules that must hold across all views and components, then load the references for concrete implementation details.

## Non-Negotiable Rules

- Development runs on port `3030` via `bin/dev`.
- Views live in `app/views/`, inherit from `Views::Base`, and use fully-qualified i18n keys.
- Components live in `app/components/`, inherit from `Components::Base`, and accept `**attrs` when they render DOM elements.
- Multi-part UI components use the compound helper pattern; views call parent helpers, not child `.new` calls.
- Stimulus defaults for interactive compound components belong in component helper methods, not repeated across views.
- Interactive overlays should use stable fixed positioning and avoid animating `top`/`left`.
- Never compose Sheet/Dialog/overlay `content` inside a container that creates a stacking context (`sticky`/`relative` + `z-index`, `transform`, `filter`, `will-change`). Keep the trigger inside the stacking container and place the overlay `content` outside it under the same Sheet root block. See [frontend/views.md](frontend/views.md#modaloverlay-composition-in-views).
- Stimulus controllers should mirror domain/view ownership in path structure (for example `app/javascript/controllers/themes/autosave_controller.js`) and use the matching identifier (`editor--themes--autosave`) in `data-controller` and `data-action`.
- Use `link_to` for navigation instead of raw anchor tags.
- Keep Tailwind usage semantic and aligned with the design system.
- Separate divergent form intents into dedicated components (for example editor vs settings) instead of mode-driven branching in one large component.
- Forms must visibly render field-level validation errors. Prefer `form.field` (which renders `field_errors` automatically). If using raw inputs like `file_field`/`text_field`, explicitly render the related errors below the input.

## Practical Workflow

1. Decide whether the work belongs in a view, reusable component, or Stimulus controller.
2. Load the matching reference file below.
3. Implement with explicit data flow from controller to view/component.
4. If the feature is interactive, wire `data-*` defaults through the component and keep behavior in Stimulus.

## Reference Map

- **[references/views.md](frontend/views.md)**
  Use for view namespaces, controller-to-view integration, and page composition patterns.
- **[references/components.md](frontend/components.md)**
  Use for component conventions, `initialize(**attrs)`, and compound-component usage.
- **[../../stimulus/SKILL.md](../../stimulus/SKILL.md)**
  Stimulus controller rules (lifecycle, declared surface, Turbo, naming, wiring).
- **[references/form-snapshot.md](frontend/form-snapshot.md)**
  Use when working on complex forms and preserving existing UI/form structure during refactors.
- **[references/chadcn-editor-form-builder.md](frontend/chadcn-editor-form-builder.md)**
- **[references/layout-stability-cls.md](frontend/layout-stability-cls.md)**
  Use for preventing Cumulative Layout Shift in paginated tables, text truncation patterns, and fixed-height containers.

## Companion Skills

- **[../phlex-view-pattern/SKILL.md](../SKILL.md)** — **PRIMARY view structure source**: Golden archetype for all Phlex views and components. Load this first for any work in `app/views/` or `app/components/`. This skill defers to phlex-view-pattern for view shape, presenter extraction, sub-component decomposition, and Turbo Frame ID conventions.
- **[../design-system/SKILL.md](../../design-system/SKILL.md)** for base UI components and semantic tokens
- **[turbo-frames.md](turbo-frames.md)** for frame decomposition and Turbo interaction patterns
- **[../i18n/SKILL.md](../../i18n/SKILL.md)** for translation structure and key rules

## Fast Review Heuristics

- If a controller is shaping UI state instead of passing explicit data, the frontend boundary is probably wrong.
- If a view repeats the same DOM pattern in multiple places, it probably wants a component.
- If a component owns behavior but not markup defaults, the Stimulus integration is probably leaking into the view layer.
- If a link is written as raw `<a>`, it is probably missing Rails/Turbo behavior.

