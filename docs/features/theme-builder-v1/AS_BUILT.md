# Theme builder v1: as built

What the epic `theme-builder-v1` shipped and the decisions taken on the way. Conventions are in `.ai/skills/`; this records outcomes.

## Derivation (`Themes::Service::Harmony`)

Pure, oklch, no I/O. Inputs (`Themes::Contract::Inputs`): `primary`, `tint` (0..1, default 0.4), `radius` (default `0.625rem`),
`chart_offsets` (5 hue offsets, each within -360..360, default -40, -20, 0, 20, 40) and `overrides` (per mode, per variable).
Output is a `Chadcn::Theme::Palette` (`root` and `dark`) plus the number of contrast repairs.

Constants as measured:

| Constant | Value |
|---|---|
| Light lightness steps | sidebar .985, secondary/muted/accent .967, border/input .92, muted-foreground **.54**, foreground .141, secondary-/accent-foreground .21 |
| Dark lightness steps | background .141, card/popover/sidebar .21, secondary/muted/accent .274, muted-foreground .705, foregrounds .985 |
| Neutral chroma max | 0.015 |
| Muted-foreground chroma min | light 0.016, dark 0.015 |
| Dark primary | lightness +0.15 (max 0.92), chroma x0.8 |
| Ring | lightness .705 light / .552 dark, chroma x0.6 |
| Charts | lightness .65 light / .70 dark, chroma min 0.12 |
| Destructive | `oklch(0.577 0.245 27.325)` light, `oklch(0.704 0.191 22.216)` dark |
| Dark border / input | `oklch(1 0 0 / 10%)` / `oklch(1 0 0 / 15%)` |
| Contrast repair | step 0.05, at most 10 steps; a failing primary pair shifts the primary by 0.1 once |

Light muted-foreground is 0.54, not zinc's 0.552: 0.552 on the muted surface measures 4.37:1, under the strict 4.5:1 bar. The
`theme-science` skill still lists 0.552 (a skill correction is for a maintainer; `.ai/skills` was outside the item's Owns).
`Chadcn::Theme` is the only validator (format, completeness, contrast).

## Operations

`Themes::Operation::{Create, Update, Destroy, Derive, Publish, Unpublish}` and `Generations::Operation::{Request, Complete, Fail}`.
Failures carry a code. `Derive`: `:invalid` (contract) or `:contrast`; `Create` and `Update` pass those on and fail `:invalid`
when the record does not save. Generation (`Generations::Operation::Fail::CODES`): `:refused` (refusal stop reason), `:invalid`
(an answer not shaped like the schema, or inputs the contract rejects), `:contrast`, and `:unavailable` for the rest: an API
error, a truncated or unparseable answer, an abandoned run, exhausted retries, a failed enqueue or an unexpected job error.
`Request` fails `:busy` while a non-abandoned generation is pending and `:invalid` for a blank prompt or one over 2000
characters. `Destroy` fails `:not_destroyed`; `Publish`/`Unpublish` `:invalid`.

## Routes

| Route | Purpose |
|---|---|
| `GET /` | home |
| `resources :themes` | list, new, create, show, edit, update, destroy |
| `POST /themes/:theme_id/publication`, `DELETE ...` | publish, unpublish |
| `POST /themes/:theme_id/generations` | start a generation from a prompt |
| `POST /derivations` | derive for the live editor (Turbo Stream) |
| `GET /t/:slug.css`, `GET /t/:slug.json` | public export, published themes only |
| `GET /previews/:page` | dashboard, form, landing, settings, auth, shell |
| `GET /gallery` | components gallery |
| `GET /up` | health check |

## Editor

Groups: brand, surfaces, radius, charts, sidebar, dark, advanced. The Stimulus `editor--preview` controller sets CSS variables on
the preview root, toggles `.dark`, and submits the form to `POST /derivations` (Turbo Stream) for the server-derived palette; it
derives nothing itself. `editor--color` uses a vendored `culori`. Save permits `name` and `inputs.primary|tint|radius|overrides`;
`chart_offsets` is set only by generation (the Charts group shows the derived colors, it does not edit offsets).
Known follow-up: blank-override pruning is duplicated in `DerivationsController` and `Themes::Operation::Update`.

## Exports

- `theme.css`: `Chadcn::Theme::COLORS_START`, a `/* source: chadcn-studio <name> <url> */` line, `Chadcn::Theme.render_colors`, `COLORS_END`.
  Served as an attachment named `<slug>.css`. The comment text is one line, capped at 200 characters, with `/*` and `*/` defused.
- `theme.json`: pretty JSON with `name`, `slug`, `inputs`, `light`, `dark`.
- Only published themes are served (404 otherwise), and the palette is re-validated at serve time (`Exports::Service::Servable`).
- Import command shown in the editor: `bin/rails theme:import[<base url>/t/<slug>.css]` (alias of `chadcn:theme:import`); a round-trip test imports the served file.

## Generation

`Generations::Service::Client` is the only file naming `Anthropic::`; model `claude-opus-5-5`; it returns a `Result` (`ok`, `refused`,
`truncated`, `unavailable`) and re-raises rate-limit and connection errors as `Generations::Transient` for the job's retry. `POST /themes/:theme_id/generations` is rate-limited to 5 per minute (429). `GenerateThemeJob`
(queue `generation`) calls `Operation::Complete`: client, then `Themes::Operation::Derive`, then theme and generation saved in one
transaction, then a Turbo Stream status replace plus a page refresh. A pending generation older than 30 minutes (`Generations::Service::Deadline`) counts as
abandoned: `Complete` fails it as `:unavailable` and `Request` no longer treats it as busy. Tests stub the client with `test/support/fake_generation_client.rb`.

## Open at release

- One live smoke call with a real `ANTHROPIC_API_KEY` is still pending.
- Production hosting, the secret and the public base URL are item 15 (human).
- The public URL uses `request.base_url`, so it is correct only behind a proxy that forwards the host and scheme; the gem imports
  https URLs only, so the command shown on a plain-http host (local dev) does not import.
