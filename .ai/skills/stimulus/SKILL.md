---
name: stimulus
description: "Stimulus controllers for chadcn-studio (importmap, no bundler). Use when creating or editing files in `app/javascript/controllers/**` or when adding `data-controller`/`data-action`/targets/values to Phlex views. Covers lifecycle cleanup, declared targets/values/outlets, Turbo compatibility, naming, accessibility, wiring, and the preview controller's CSS-variable contract."
---

# Stimulus Controllers (chadcn-studio)

## Applies to
- when: `app/javascript/**/*.js`
- companion: `accessibility` always
- system-review: never
- note: The gem's `chadcn--*` controllers are not in this repository; `importmap`/vendor files are excluded by the orchestrator's track routing.

## Quick Rules
Cite as `stimulus R<n>`. Detail and examples follow below.

R1. **Behavior only.** Stimulus enhances server-rendered HTML; it never renders pages, builds markup from interpolated data, or fetches HTML (use Turbo Frames/Streams). → detail: Turbo-first
R2. **Clean up in `disconnect()`.** Everything created in `connect()` (listeners, timers, observers, `AbortController`s, appended DOM nodes) is released in `disconnect()`. → detail: Lifecycle
R3. **Survive Turbo.** Controllers must tolerate Turbo cache restore and reconnecting; no one-shot setup that assumes a single `connect()`. → detail: Lifecycle
R4. **Declare the surface.** Every `this.xTarget|xValue|xOutlet|xClass` is declared in `static targets/values/outlets/classes`, and every declaration is used. → detail: Declared surface
R5. **Actions in markup.** Prefer `data-action` in the view over `addEventListener`; when a listener is unavoidable, keep a named bound handler so it can be removed. → detail: Declared surface
R6. **Targets over selectors.** Use targets, not `document.querySelector`; reach other controllers via outlets or events (`this.dispatch`), never by importing them. → detail: Declared surface
R7. **No `innerHTML` with data.** Never assign `innerHTML` from interpolated or user-supplied strings (XSS); use `textContent` or DOM APIs. → detail: Security
R8. **State in the DOM.** State lives in values, classes or data attributes, not module-level variables. → detail: Declared surface
R9. **Copy from the view.** User-facing strings arrive through values/data attributes rendered by the Phlex view, never literals in JS. → detail: Copy
R10. **Naming and registration.** `foo_bar_controller.js` ↔ `data-controller="foo-bar"`; nested folders use `--` (`editor/preview_controller.js` ↔ `editor--preview`). Registration is by eager loading from the importmap; do not hand-register. The gem's `chadcn--*` controllers are pinned by its engine and never copied here. → detail: Naming
R11. **Accessible widgets.** Custom widgets manage focus on open/close, toggle `aria-expanded`/`aria-controls`, and handle Escape/Enter/arrows; no click-only interactions on non-buttons. → detail: `../accessibility/SKILL.md`
R12. **Reuse the gem first.** Dialog, sheet, popover, slider, tabs, theme toggle and every overlay behavior exist in the gem (`chadcn--dialog`, `chadcn--slider`, `chadcn--theme`...); compose them, never duplicate them. App controllers are for what the gem has no notion of: the live preview, the pickers, the export copy button. → detail: Reuse
R13. **Wiring is bilateral.** Each `data-controller` in a view resolves to a file, and each target/value/action a controller expects exists in the markup that uses it. → detail: Wiring
R14. **Preview contract.** The preview controller only sets CSS custom properties on the preview root (`style.setProperty("--primary", value)`) and toggles the `dark` class; it never computes a palette, never rewrites markup and never persists. Derivation is a request to the server (`theme-science` R6). → detail: Preview

## Where controllers live
`app/javascript/controllers/**` (loaded by `eagerLoadControllersFrom("controllers", application)` in `controllers/index.js`). App controllers sit under `controllers/editor/` (`editor--preview`, `editor--picker`, `editor--export`); the gem's controllers come from its engine pins and are listed by `bin/rails chadcn:doctor`.

## Lifecycle
`connect()` sets up, `disconnect()` tears down. Bind handlers once (`this.handleInput = (event) => …`) and remove the same reference. Debounced work (a slider firing a derivation request) keeps its timer id on the instance and clears it on disconnect.

## Declared surface
Declare `static targets`, `values`, `outlets`, `classes` at the top. Guard optional targets with `this.hasXTarget`. Values carry the data (`static values = { variables: Object, mode: String }`), the view renders them.

## Turbo-first
Server responses are HTML via Turbo. Do not `fetch` fragments to inject; do not rely on `DOMContentLoaded`; form submissions go through Turbo with `requestSubmit()` where needed. The generation result arrives as a Turbo Stream that replaces the editor's inputs; the preview controller reacts to the resulting value change (`variablesValueChanged`), not to a custom fetch.

## Security
No `innerHTML` with dynamic data; no `eval`/`new Function`. A CSS variable value coming from the server is set with `setProperty`, which cannot inject markup, but the server has validated it through `Chadcn::Theme` first.

## Copy
Pass copy as values (`data-editor--export-copied-label-value="Copied"`) rendered by Phlex, so the view stays the single place that owns strings.

## Naming
Folders map to `--` in identifiers. Domain names, no abbreviations (`naming-conventions`).

## Reuse
Before writing a controller, list `app/javascript/controllers/` and the gem's controllers (`bin/rails chadcn:doctor`, or `app/javascript/controllers/chadcn/` in the sibling checkout `../chadcn`).

## Preview
The preview root is one element (`data-controller="editor--preview"`) that wraps the preview pages. The controller:
- reads `variablesValue` (a `{ "--primary": "oklch(...)", ... }` object rendered by the view) and applies each entry with `setProperty`;
- toggles `dark` on the same root for the dark mode switch and reads the dark variables from a second value;
- formats an oklch string only when a slider moves (`oklch(L C H)` from three numbers); that is the only color code allowed in JavaScript;
- dispatches `editor--preview:change` so the export panel can mark itself stale.

## Wiring
Check both directions when reviewing: view → controller file, controller declarations → markup. Mismatched identifiers fail silently in the browser.

## Related
`../phlex-view-pattern/SKILL.md` (views that carry the data attributes), `../design-system/SKILL.md` (the gem's controllers), `../theme-science/SKILL.md` (what the preview may and may not compute), `../accessibility/SKILL.md`, `../testing/SKILL.md` (system tests for Hotwire flows).
