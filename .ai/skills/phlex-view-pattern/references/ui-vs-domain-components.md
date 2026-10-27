# UI vs. Domain Component Separation

## RULE 3 — Strict UI vs. Domain Component Separation

## RULE — Form Errors Must Be Visible

When a form re-renders with an invalid model (`status: :unprocessable_entity`), users must be able to see and fix field-level errors in the same surface.

- Prefer `Chadcn::Field` with its error slot so field-level errors render next to the input.
- If a component uses raw helpers (`file_field`, `text_field`, `text_area`, etc.), it must explicitly render `field_errors` (or equivalent model error output) for each editable field.
- If a form lives in an overlay/sheet/modal, keep that surface open on failure so errors are not hidden in closed DOM.

Failure to surface errors is a UX regression and a review blocker.

### `app/components/ui/` — Generic shadcn/Phlex Primitives

- Ports of shadcn/ui components: Card, Button, Table, Badge, Dialog, Sheet, etc.
- Must accept `**attrs` and forward all caller HTML attributes without discarding them.
- Must be **purely generic** — zero knowledge of this app's models, named routes or copy.
- No domain vocabulary (`theme`, `palette`, `generation`) may appear inside a `ui/` component.

### `app/views/` — Domain Page Views

- Allowed to accept ActiveRecord models, domain presenters and plain Ruby values.
- Allowed to call named route helpers and domain-specific translation keys.
- These are assembled pages, not reusable components.

### `app/components/shared/` — Cross-Domain Helpers

Small shared components (Flash, LanguageToggle, ThemeToggle) used across all domains.
No model knowledge; no route coupling.

### `app/components/` — editor-Scoped Layout Components

Layout-level components like `Navbar` that belong to a single domain but are not page
views. May reference editor-scoped routes and translations.

### ❌ Forbidden — domain logic inside a UI component

```ruby
# Inside Components::Ui::Card — NEVER add domain-specific logic
def render_theme_status(theme)
  span { theme.published? ? t("themes.published") : t("themes.draft") }
end
```

---
