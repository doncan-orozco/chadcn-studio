---
name: naming-conventions
description: "Domain-language naming rules for classes, methods, variables, keyword arguments and Stimulus values. Use when naming or renaming any new class, method, variable, operation, route, concept or Stimulus controller in chadcn-studio; the library exception keeps the shadcn vocabulary of the chadcn gem 1:1."
---

# Naming Conventions

## Quick Rules

Cite as `naming-conventions R<n>`. Detail and examples follow below.

R1. **Domain vocabulary.** Class, method and variable names use domain terms, not technical implementation terms (`Palette`, not `ColorHash`; `Harmony`, not `ColorCalculator`). → detail: Core Principle / Classes and Types
R2. **No stuttering.** Class and file names never repeat the namespace or type (`Recent`, not `RecentQuery`). → detail: Classes and Types
R3. **Domain types over primitives.** Compound domain concepts get their own type (`Oklch` with lightness, chroma and hue) instead of raw String/Float/Hash. → detail: Classes and Types
R4. **Methods name the outcome.** Methods are named for what they accomplish (`readable_on?(background)`), not how (`check_contrast_ratio`). → detail: Methods
R5. **Domain verbs for commands.** Command methods use domain verbs (`derive`, `publish`, `export`), not persistence verbs (`save`, `insert`, `update`). → detail: Methods
R6. **Predicates end in `?`.** Boolean methods end in `?` and read as domain assertions; avoid negated names (`valid?`, not `not_invalid?`). → detail: Methods
R7. **Bang only with counterpart.** `!` methods exist only when a safe non-bang counterpart exists (`publish` vs `publish!`). → detail: Ruby-Specific Guidance
R8. **Domain variable names.** Variables and iterators carry the domain term (`primary`, `neutral_steps`, `variables.each do |variable|`), not `item`, `data`, `result`, `obj` or `color2`. → detail: Variables and Parameters / Avoid
R9. **Booleans read as assertions.** Boolean variables and parameters are named like `dark_mode` or `requires_repair`, not `flag` or `bool_val`. → detail: Variables and Parameters
R10. **No cryptic abbreviations or suffixes.** No `usr`, `cfg`, `mgr`, `tmp`, and no `_hash`/`_array`/`_list` suffixes unless the structure is the domain concept. The oklch letters `l`, `c`, `h` are domain vocabulary and allowed inside color math only. → detail: Avoid
R11. **Keyword args when ambiguous.** Use keyword arguments when two or more arguments share a type and order is not self-evident (`contrast(foreground:, background:)`). → detail: Method Arguments and Keyword Parameters
R12. **Constants and casing.** Constants are `SCREAMING_SNAKE_CASE` domain values (`NEUTRAL_CHROMA`, `DARK_PRIMARY_LIFT`); classes and modules are `PascalCase`; everything else is `snake_case`. → detail: Ruby-Specific Guidance
R13. **Library exception.** Names that mirror the shadcn theme or component API stay exactly as shadcn spells them: the CSS variables (`--muted-foreground`, `--sidebar-primary`, `--chart-1`), `Chadcn::Dialog::Content`, `as_child`, `data-slot`. A Ruby identifier for a variable is its snake_case form (`muted_foreground`), never a renamed concept. → detail: Library exception

## Core Principle
Code should read like domain discussion. A designer reading the harmony rule in Ruby should recognise every word: primary, neutrals, foreground, contrast, chroma, lightness, hue, radius, preset, export.

## Classes and Types
- Name types after the domain concept they represent, not after their technical implementation.
- Never repeat the namespace or type in the class or file name: `Themes::Query::Recent`, `Themes::Service::Harmony`, `Exports::Presenter::Css`.
- Compound domain concepts get their own type: an `Oklch` value has `lightness`, `chroma` and `hue`, not a three-element array; a `Palette` is the set of variables for one mode, not a Hash passed around.
- Never expose implementation-level details in a class name: `VariableMap` is worse than `Palette`.

## Methods
- Name methods after what they accomplish in the domain, not how they do it.
- Predicate methods (`complete?`, `readable_on?`, `dark?`) read as assertions about the domain state.
- Command methods (`derive`, `publish`, `repair`) use the domain verb, not the persistence verb.

## Variables and Parameters
- Name variables after what they hold in the domain: `primary`, `neutral`, `ring`, `foreground`, not `color1`, `tmp`, `val`.
- Iterator variables carry the domain term: `variables.each do |variable|`, `steps.each do |step|`.
- Boolean variables and parameters read as domain assertions: `dark_mode`, `strict`.

## Method Arguments and Keyword Parameters
- Prefer keyword arguments when two or more arguments share a type and the order is not self-evident: `contrast(foreground:, background:)` beats `contrast(a, b)`.

## Library exception (names that mirror shadcn)
R1 does not apply to names whose purpose is to reproduce the shadcn/ui API or theme format. The variable names, the component classes and their kwargs are the domain language and are kept 1:1 even where they would not be our choice (the `chadcn` gem's `naming-conventions` says the same). R2 and R4 to R12 still apply to this app's own classes and helpers.

## Stimulus
Controller files and identifiers follow `stimulus` R10: `editor/preview_controller.js` ↔ `editor--preview`. Values are named after the domain (`data-editor--preview-variables-value`), never after their type.

## Avoid
- Abbreviations that are not universal in the domain (`usr`, `cfg`, `mgr`, `tmp`); `bg`/`fg` are allowed only where shadcn itself uses them (`bg-primary`).
- Technical suffixes that leak implementation (`_hash`, `_array`, `_list`) unless the data structure is itself the domain concept.
- Generic container names (`data`, `result`, `obj`, `thing`, `item`) outside of very narrow local scope.
- Negated names that force double-negation reading.

## Ruby-Specific Guidance
- Boolean predicate methods end in `?`.
- Destructive methods end in `!` only when a safe counterpart exists.
- Constants use `SCREAMING_SNAKE_CASE` and are named after the domain value: `NEUTRAL_CHROMA`, `RING_LIGHTNESS`, `CHART_HUE_SPREAD`.
- Module and class names use `PascalCase`; all other names use `snake_case`.

## Questions to Ask Before Naming
1. If a designer reads this name, does it mean the same thing to them as it does to you?
2. Does the name carry its intent without requiring a comment?
3. Would renaming this reveal a missing domain concept (an `Oklch` type, a `Palette`) that should be modeled explicitly?
4. Does the name say *what* it is, not *how* it is stored or processed?
