---
name: theme-science
description: "The domain of chadcn-studio: the shadcn theme variable set, oklch as the working color space, the harmony rule that derives a full light and dark theme from a primary color, validation through `Chadcn::Theme`, and the export formats (theme.css with markers, the per-theme URL, JSON). Use when writing or reviewing `Themes::Service::Harmony`, the derive/export operations, the palette columns, the preview controller, or any code that reads or writes a theme variable."
---

# Theme Science

A theme is the set of CSS custom properties shadcn v4 components read: 32 color variables in `:root` and again in `.dark`, plus `--radius` in `:root`. The gem's `Chadcn::Theme` knows the set (`REQUIRED`, `ROOT_ONLY`), parses it, renders it, and judges it (format, completeness, text contrast). This app adds one thing: a rule that produces a whole theme from a few choices, so a user picks a primary color and gets a coherent light and dark theme, then adjusts by hand.

## Quick Rules

Cite as `theme-science R<n>`. Detail in references/.

R1. **The variable set is the gem's.** The names come from `Chadcn::Theme::REQUIRED` and `ROOT_ONLY`; the app never hard-codes the list, never invents a variable, never drops one. A new shadcn variable appears here by bumping the gem. → references/variables.md
R2. **A palette is `{ root:, dark: }` keyed by variable name.** Everywhere (columns, operations, presenters, the preview value) a palette is the gem's shape: `Chadcn::Theme::Palette` with string keys without the leading dashes and string values in CSS syntax. → `models` R8, `sqlite` R15
R3. **oklch is the working space.** Every color the app writes is `oklch(L C H)` with L in 0..1 (three decimals), C in 0..0.4 (three decimals), H in 0..360 (three decimals); `oklch(L C H / A%)` only for the two dark-mode alpha variables (`border`, `input`). A value typed as hex or hsl by a user or returned by the model is converted once, at the contract. → references/variables.md
R4. **`Chadcn::Theme` is the only validator.** Completeness, format safety and text contrast are judged by `Chadcn::Theme.validate(palette, strict:)` and pairs by `Chadcn::Theme.contrast(fg, bg)`; the app never re-implements a contrast formula, never keeps a second list of pairs. These methods are reachable but tagged `@api private` in the gem: the app pins the gem version and the gem promotes them to the public API (a `chadcn` follow-up), rather than the app copying them. → Validation
R5. **The harmony rule lives in one service.** `Themes::Service::Harmony.call(inputs) -> Palette` is pure (no I/O, no persistence) and is the only place color arithmetic happens in Ruby; operations call it, presenters format its output, nothing else computes a color. → references/derivation.md
R6. **JavaScript previews, Ruby derives.** The browser sets the variables it is given on the preview root and formats one oklch string when a slider moves; it never derives a second variable from a first. Derivation is a request (`Themes::DerivationsController#create`) that returns the whole palette. → `stimulus` R14
R7. **Inputs are few.** The user (or the model) chooses: primary (oklch), neutral tint strength (0..1), radius (rem), chart hue offsets (optional), and per-variable overrides (optional). Everything else is derived; an override wins over the rule for that variable only and survives re-derivation. → references/derivation.md
R8. **Foregrounds are chosen by contrast, then repaired.** Each `*-foreground` is the lighter or darker candidate with the higher contrast against its surface; after derivation a strict validation runs and a bounded repair nudges lightness until every pair reaches 4.5:1, or the operation fails with `:contrast`. → references/derivation.md
R9. **Dark mode is derived, not inverted.** Dark neutrals use their own lightness steps (the zinc dark steps), the primary is lifted (L +0.10 to +0.20, C ×0.8) and `border`/`input` are white with alpha, exactly as the shadcn presets do. → references/derivation.md
R10. **Destructive is fixed.** `--destructive` is the shadcn red in both modes; it is not derived from the primary and the user does not edit it in v1. → references/variables.md
R11. **Exports are the gem's text.** The CSS export is `Chadcn::Theme.render_colors(palette)` between the `theme:colors:start/end` markers with a `/* source: ... */` line, which is also what ui.shadcn.com/themes produces; the JSON export is the palette plus name and slug; the URL export is the CSS export served over https at a stable path that `bin/rails chadcn:theme:import[url]` accepts. → Exports
R12. **Values are untrusted until validated.** A value from a form, a URL import or the model is text that could break `theme.css`; nothing is saved, rendered into a `style` attribute or exported before `Chadcn::Theme.validate` returns no errors. → `llm-generation` R8

## The variables

| Group | `:root` and `.dark` | Only `:root` |
|---|---|---|
| Surfaces | `background`, `card`, `popover`, `sidebar` | |
| Text on surfaces | `foreground`, `card-foreground`, `popover-foreground`, `sidebar-foreground` | |
| Brand | `primary`, `primary-foreground`, `sidebar-primary`, `sidebar-primary-foreground` | |
| Secondary | `secondary`, `secondary-foreground`, `accent`, `accent-foreground`, `sidebar-accent`, `sidebar-accent-foreground` | |
| Muted | `muted`, `muted-foreground` | |
| Lines | `border`, `input`, `ring`, `sidebar-border`, `sidebar-ring` | |
| Semantic | `destructive` | |
| Data | `chart-1` … `chart-5` | |
| Shape | | `radius` |

Full table with the zinc values and the text pairs the contrast check reads: [references/variables.md](references/variables.md).

## The harmony rule (summary)

1. **Primary** is the input `oklch(L C H)`.
2. **Neutral hue** is the primary hue; **neutral chroma** is `tint × 0.015` (tint 0..1; 0.4 reproduces zinc's tint).
3. **Light neutrals** take zinc's light lightness steps (background 1, sidebar 0.985, secondary/muted/accent 0.967, border/input 0.92, muted-foreground 0.552, foreground 0.141) at the neutral hue and chroma.
4. **Dark neutrals** take zinc's dark steps (background 0.141, card/popover/sidebar 0.21, secondary/muted/accent 0.274, muted-foreground 0.705, foreground 0.985); `border` and `input` are `oklch(1 0 0 / 10%)` and `/ 15%`.
5. **Dark primary** is the primary lifted toward readability on dark surfaces (L + 0.15 clamped to 0.92, C × 0.8).
6. **Foregrounds** are chosen by contrast between the near-white (0.985) and near-black (0.141) neutral candidates.
7. **Ring** is the primary hue at L 0.705 (light) / 0.552 (dark) with C × 0.6.
8. **Charts** are five hues at offsets −40, −20, 0, +20, +40 from the primary hue, L 0.65 (light) / 0.70 (dark), C max(primary C, 0.12).
9. **Sidebar** mirrors: `sidebar` = sidebar step, `sidebar-primary` = primary, `sidebar-accent` = accent, `sidebar-border` = border, `sidebar-ring` = ring, with the matching foregrounds.
10. **Destructive** fixed; **radius** is the input (default 0.625rem).
11. **Repair**: strict validation, then up to 10 steps of ±0.05 on the failing foreground's lightness, then one nudge of the primary away from mid-lightness; still failing is `:contrast`.

The constants (`NEUTRAL_CHROMA_MAX`, the step tables, `DARK_PRIMARY_LIFT`, `RING_LIGHTNESS`, `CHART_HUE_OFFSETS`) live in `Themes::Service::Harmony` and are the only tunables. Worked example and the full table: [references/derivation.md](references/derivation.md).

## Validation

```ruby
palette = Themes::Service::Harmony.call(inputs)
result = Chadcn::Theme.validate(palette, strict: true)   # { errors: [...], warnings: [...] }
```

`errors` is empty for a theme the gem will import; `warnings` lists unknown variables and, when not strict, weak contrast. The presenter shows warnings next to the group that owns the variable.

## Exports

| Format | Produced by | Consumed by |
|---|---|---|
| `theme.css` block | `Exports::Presenter::Css` → `Chadcn::Theme.render_colors` between the markers, `/* source: chadcn-studio <url> */` | paste into any chadcn app's `theme.css`, or ui.shadcn.com-compatible tools |
| URL | `GET /themes/:slug/export.css` over https, no auth, `text/css`, under 256 KiB | `bin/rails chadcn:theme:import[https://…/export.css]` (the gem follows at most three redirects, refuses non-https, and rejects values matching its `UNSAFE_VALUE`) |
| JSON | `Exports::Presenter::Json` → `{ name, slug, light: {…}, dark: {…} }` | the generation round trip, other tools |

With Tailwind 4 there is no `tailwind.config.js` to export: the CSS variables are the theme.

## Preview

The preview root receives the palette as two values (`light`, `dark`) and the mode; `editor--preview` applies the current mode's variables with `style.setProperty("--<name>", value)` and toggles `dark`. Because the gem's `tokens.css` maps `--color-primary: var(--primary)` and friends, every component inside the root repaints without a Tailwind rebuild. Nothing outside the root changes.

## Related
`design-system` (the preview pages and the gallery), `llm-generation` (where the inputs may come from), `models`/`sqlite` (how a palette is stored), `testing` R7 (table-driven tests with the gem as oracle).
