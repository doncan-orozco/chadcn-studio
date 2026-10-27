---
name: design-system
description: "Using the chadcn gem (shadcn/ui ported to Phlex: `Chadcn::*`, `chadcn--*` Stimulus controllers, shadcn-format theme) in chadcn-studio: composing components in views, the theme file and tasks, and the rules of the preview pages and the components gallery built from `Chadcn::Catalog`. Use when composing components in views, building a preview page, or touching `app/assets/tailwind/theme/`."
---

# Design System (the `chadcn` gem)

The design system is the `chadcn` gem (doncan-orozco/chadcn, sibling checkout `../chadcn`, live through `bundle config set --local local.chadcn ../chadcn`): a 1:1 Phlex port of shadcn/ui (new-york-v4, Radix behavior in Stimulus). How a component is ported and verified is the gem's business (`shadcn-port`, `radix-stimulus` there). This skill is the day-to-day contract for **using** the components here, plus the two things only this app has: the preview pages and the gallery.

## Quick Rules

Cite as `design-system R<n>`.

R1. **Semantic tokens only.** `bg-primary`, `text-muted-foreground`, `border-input`...; no palette classes, hex, rgb or oklch literals in any view, component or stylesheet. The only color classes allowed are the ones the shadcn source itself uses (`text-white`, `bg-black/50`). → `theme-science` R1
R2. **Namespace and location.** Components are `Chadcn::<Name>` from the gem; Stimulus identifiers are `chadcn--<name>`. The app never defines a `Components::Ui::*` copy of a gem component.
R3. **Same API as React.** One Ruby class per React export: `Dialog` -> `Chadcn::Dialog`, `DialogContent` -> `Chadcn::Dialog::Content`. Props are snake_case kwargs; `className` -> `class:`; children -> block.
R4. **Two equivalent ways to compose parts.** Explicit `render Chadcn::Dialog::Content.new(...) { }` (canonical) or the generated yielded-root helpers (`dialog.content { }`); a helper is exactly `render Root::Part.new(**attrs), &block`. Mixing both in one view is fine. → references/compound-components.md
R5. **`**attrs` everywhere.** Every component takes `**attrs`, merges `class` via `cn` (caller wins) and deep-merges `data:`/`aria:`; app code passes its Stimulus wiring through them.
R6. **Strings and symbols.** Variant-like options accept both (`variant: "outline"`, `variant: :outline`); defaults equal the React `defaultVariants`.
R7. **`data-slot` on every part** is emitted by the gem; app code never adds or renames one.
R8. **No button inside a trigger part.** `Dialog::Trigger` renders its own `<button>`; to render it as a Button use `Dialog::Trigger.new(as_child: Chadcn::Button.new(variant: "outline"))`.
R9. **Behavior through the gem's controllers.** No inline JS, no per-component copies of focus/dismiss/positioning logic; app controllers only add what the gem has no notion of (`stimulus` R12).
R10. **Theme in shadcn format, one file.** The app's own look lives in `app/assets/tailwind/theme/theme.css` between the `theme:colors:start/end` markers; `tokens.css` is the gem's and never edited. Switch with `bin/rails theme:use[preset]`, `theme:import[file-or-url]`, check with `theme:check`. The editor's chrome uses this file; the previews override it at runtime (R12). → `theme-science`
R11. **Gallery from the Catalog.** The components gallery page renders `Chadcn::Catalog.entries` through `Chadcn::Catalog::TreeRenderer`; no hand-written demos that can drift from the gem.
R12. **Preview root overrides, nothing else does.** The only place CSS variables are set outside `theme.css` is the preview root element, by the `editor--preview` controller from server-rendered values (`style` attribute on one element). No `<style>` blocks, no per-component inline colors.
R13. **Every variable is exercised.** Each of the theme variables (light and dark) appears visibly in at least one preview page (`--chart-*` in the dashboard, `--sidebar-*` in the app shell preview, `--destructive` in a form's danger action...); a test walks `Chadcn::Theme` variable names against the preview sources. → `theme-science` references/variables.md
R14. **Verified upstream, not patched here.** A `Chadcn::*` look or behavior is never patched locally (no monkey patches, no ejected components in v1); change it in doncan-orozco/chadcn, run its gates, bump the lock (`bundle update chadcn`).
R15. **Preview pages are fixtures, not features.** A preview page (dashboard, form, landing, settings, auth) takes a presenter of static sample data (`Previews::Presenter::*`), has no routes of its own beyond `/previews/:page`, no persistence and no domain logic; it exists to show the theme.

## Using components (what a view looks like)

```ruby
render Chadcn::Dialog.new do |dialog|
  dialog.trigger(as_child: Chadcn::Button.new(variant: "outline")) { "Colors" }
  dialog.content(class: "sm:max-w-[520px]") do
    dialog.header do
      dialog.title { "Colors" }
      dialog.description { "Pick the primary color; the rest follows." }
    end
    render Components::Editor::PrimaryPicker.new(primary: @presenter.primary)
    dialog.footer { render Chadcn::Button.new(type: "submit", form: "theme-form") { "Apply" } }
  end
end
```

Components that are not compound parts (`Button`, `Input`, `Slider`...) are always rendered by their class.

## The gem's tooling you will use
- `bin/rails chadcn:doctor` checks the install (pins, theme files, Tailwind block).
- `bin/rails theme:list|use|import|check` manage the app's own `theme.css`.
- `Chadcn::Theme.validate(palette, strict: true)` and `Chadcn::Theme.contrast(fg, bg)` are the validation oracle (`theme-science` R4).
- `Chadcn::Catalog.entries` / `Chadcn::Catalog.find("dialog")` give the gallery its examples.

## Companion skills
- `theme-science`: variables, harmony rule, exports.
- `stimulus`: app controllers and the preview contract.
- `phlex-view-pattern`: dumb views, presenters, domain components.
- `accessibility`: WCAG checks for the editor chrome.

## Quick commit check
- No color literal outside `theme.css` and the preview root (grep `oklch(|#[0-9a-f]{3,6}|rgb(` in `app/` finds only `theme.css` and the preview controller's formatter).
- The gallery renders without a hand-written example.
- `bin/rails chadcn:doctor` green after a lock bump.
