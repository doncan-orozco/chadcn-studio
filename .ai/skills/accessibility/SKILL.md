---
name: accessibility
description: "WCAG 2.2 AA accessibility for chadcn-studio Phlex views and components. Use when editing files in `app/views/` or `app/components/` for focus states, contrast, keyboard navigation, ARIA labels on icon-only controls, overlay triggers, color pickers and sliders, or writing accessibility system tests."
---

# Accessibility (WCAG 2.2 AA)

## Quick Rules

Cite as `accessibility R<n>`. Detail and examples follow below / in references/.

R1. **Keyboard reachable.** All interactive controls are keyboard reachable and visibly focusable. → detail: Non-Negotiable Rules
R2. **Focus parity.** Every hover affordance on links/buttons has a matching `focus-visible` one (e.g. `hover:underline` + `focus-visible:underline`). → detail: Common Fix Patterns
R3. **Not color alone.** State is never communicated by color alone; in a theme builder this includes the "contrast failing" state, which carries text or an icon, not only a red border. → detail: Non-Negotiable Rules
R4. **Icon-only names.** Icon-only controls expose an accessible name via `aria-label` or adjacent sr-only text. → detail: Common Fix Patterns
R5. **Semantic first.** Use `button`, `a`, `nav`, `time[datetime]`, lists and headings before adding ARIA. → detail: Non-Negotiable Rules
R6. **Readable secondary text.** Body/help/metadata text is not excessively muted (prefer `text-foreground/70` over faint variants). → detail: Common Fix Patterns
R7. **Overlay triggers explicit.** Modal/sheet/dialog/menu triggers carry `aria-haspopup="dialog"` and `aria-controls` when practical; the gem's `Dialog::Trigger` already does, so use it rather than a bare button. → detail: Common Fix Patterns
R8. **Pickers and sliders are labelled.** Every slider (`Chadcn::Slider`) and color input has a visible label and an `aria-valuetext` that reads as the domain value ("Lightness 62%"), not a raw number. → detail: Editor controls
R9. **The editor's own chrome keeps AA.** The editor UI is rendered with the default preset, outside the preview root, so a user editing a low-contrast theme can still read the controls. → detail: Editor controls
R10. **System test coverage.** Changed surfaces get a system test under `test/system/...` asserting `aria-label`/`aria-haspopup`/`aria-controls` and focus parity classes. → detail: Testing Guidance

Use this skill to enforce accessible UI behavior while implementing or reviewing frontend work.

## Non-Negotiable Rules

- Keep all interactive controls keyboard reachable and visibly focusable.
- Match hover affordances with `focus-visible` affordances on links and buttons.
- Do not rely on color alone to communicate state.
- Ensure icon-only controls expose an accessible name via `aria-label` or adjacent sr-only text.
- Use semantic elements first (`button`, `a`, `nav`, `time[datetime]`, lists, headings).
- Keep text contrast readable for secondary content; avoid excessively muted text for body/help copy.
- Keep modal/sheet/dialog triggers explicit with `aria-haspopup="dialog"` and `aria-controls` when practical.

## Editor controls

The sidebar groups open dialogs full of sliders and color inputs. Each control is a `Chadcn::Field` with a `Label`, the slider or `input[type=color]`, and a description that states the unit. The preview pages are a demonstration surface: they are not required to pass AA for an arbitrary user theme (that is what the contrast check reports), but the editor chrome around them is, so it stays on the default preset.

## Practical Workflow

1. Identify the UI surface and interaction model (link, button, menu trigger, modal trigger, slider, status text).
2. Apply semantic markup before adding ARIA attributes.
3. Add or correct accessible names for icon-only controls and unlabeled triggers.
4. Add focus-visible parity for hover-only styles.
5. Increase low-contrast helper/metadata text where readability is weak.
6. Validate with a focused system test for the changed surface.

## Common Fix Patterns

- Link styles: add `hover:underline` and `focus-visible:underline` together.
- Icon-only menu/button triggers: add `aria: { label: "..." }` and keep sr-only text fallback where already used.
- Menu/dialog trigger semantics: use the gem's trigger parts, which emit `aria-haspopup` and `aria-controls`.
- Secondary text readability: prefer classes such as `text-foreground/70` over overly faint muted variants.

## Testing Guidance

- Add system tests near the feature (`test/system/...`) for changed behavior.
- Assert both semantics and behavior when possible: presence of `aria-label`, `aria-haspopup`, `aria-controls`, expected focus parity classes for critical controls.
- Use existing test hooks (`:testid`) for unstable or async UI surfaces.

## Reference Map

- **[references/wcag-pass-checklist.md](references/wcag-pass-checklist.md)** implementation-time and review-time acceptance checks.
- Pair with **[../phlex-view-pattern/SKILL.md](../phlex-view-pattern/SKILL.md)** for view/component structure.
- Pair with **[../testing/references/hotwire-system-testing.md](../testing/references/hotwire-system-testing.md)** when adding accessibility system tests.
