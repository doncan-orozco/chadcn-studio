# The harmony derivation

`Themes::Service::Harmony.call(inputs) -> Chadcn::Theme::Palette`. Pure function; the constants are its only tunables.

## Inputs

| Input | Type | Default | Notes |
|---|---|---|---|
| `primary` | `Oklch` (L, C, H) | zinc's `0.21 0.006 285.885` | the one choice the user has to make |
| `tint` | Float 0..1 | 0.4 | how much of the primary hue the neutrals carry; 0 is pure gray |
| `radius` | String (rem) | `"0.625rem"` | passed through |
| `chart_offsets` | five Floats (degrees) | `[-40, -20, 0, 20, 40]` | relative to the primary hue |
| `overrides` | `{ "light" => { name => value }, "dark" => {...} }` | `{}` | per-variable hand edits, applied last |

## Constants

```ruby
NEUTRAL_CHROMA_MAX = 0.015
LIGHT_STEPS = { "background" => 1.0, "sidebar" => 0.985, "secondary" => 0.967, "muted" => 0.967, "accent" => 0.967,
                "border" => 0.92, "input" => 0.92, "muted-foreground" => 0.552, "foreground" => 0.141 }.freeze
DARK_STEPS  = { "background" => 0.141, "card" => 0.21, "popover" => 0.21, "sidebar" => 0.21,
                "secondary" => 0.274, "muted" => 0.274, "accent" => 0.274, "muted-foreground" => 0.705, "foreground" => 0.985 }.freeze
DARK_PRIMARY_LIFT = 0.15        # added to L, result clamped to 0.92
DARK_PRIMARY_CHROMA = 0.8       # multiplier
RING_LIGHTNESS = { light: 0.705, dark: 0.552 }.freeze
RING_CHROMA = 0.6               # multiplier of the primary chroma
CHART_LIGHTNESS = { light: 0.65, dark: 0.70 }.freeze
CHART_CHROMA_MIN = 0.12
DESTRUCTIVE = { light: "oklch(0.577 0.245 27.325)", dark: "oklch(0.704 0.191 22.216)" }.freeze
DARK_ALPHA = { "border" => "oklch(1 0 0 / 10%)", "input" => "oklch(1 0 0 / 15%)" }.freeze
FOREGROUND_CANDIDATES = { light: 0.985, dark: 0.141 }.freeze   # lightness of the two text candidates
REPAIR_STEP = 0.05
REPAIR_MAX_STEPS = 10
```

## Steps

1. **Neutral color.** `neutral(l) = Oklch.new(l, tint * NEUTRAL_CHROMA_MAX, primary.hue)`; `background` in light is `oklch(1 0 0)` regardless of tint (white stays white).
2. **Light surfaces.** `background`, `card`, `popover` = white; `sidebar` = neutral(0.985); `secondary`, `muted`, `accent` = neutral(0.967); `border`, `input` = neutral(0.92).
3. **Light text.** `foreground`, `card-foreground`, `popover-foreground`, `sidebar-foreground` = neutral(0.141); `muted-foreground` = neutral(0.552) with chroma raised to `max(neutral chroma, 0.016)` so muted text keeps a hint of hue; `secondary-foreground`, `accent-foreground` = neutral(0.21).
4. **Light brand.** `primary` = input; `primary-foreground` = candidate with the higher `Chadcn::Theme.contrast` against `primary` (white candidate `oklch(0.985 0 0)` vs dark candidate neutral(0.141)).
5. **Light lines.** `ring` = `Oklch.new(0.705, primary.chroma * 0.6, primary.hue)`.
6. **Charts (both modes).** `chart-n` = `Oklch.new(CHART_LIGHTNESS[mode], max(primary.chroma, 0.12), (primary.hue + offset) % 360)`.
7. **Dark surfaces.** From `DARK_STEPS` at the neutral hue/chroma; `border`, `input` from `DARK_ALPHA`.
8. **Dark text.** `foreground` and the surface foregrounds = neutral(0.985); `secondary-foreground`, `accent-foreground` = neutral(0.985); `muted-foreground` = neutral(0.705) with chroma ≥ 0.015.
9. **Dark brand.** `primary` = `Oklch.new(min(primary.l + 0.15, 0.92), primary.chroma * 0.8, primary.hue)`; `primary-foreground` by contrast as in step 4.
10. **Dark lines.** `ring` = `Oklch.new(0.552, primary.chroma * 0.6, primary.hue)`.
11. **Sidebar (both modes).** `sidebar-primary` = `primary`, `sidebar-primary-foreground` = `primary-foreground`, `sidebar-accent` = `accent`, `sidebar-accent-foreground` = `accent-foreground`, `sidebar-border` = `border`, `sidebar-ring` = `ring`.
12. **Fixed.** `destructive` from `DESTRUCTIVE`; `radius` from the input into `root` only.
13. **Overrides.** Replace the named variables in the named mode; an override is validated like any value and is not re-derived.
14. **Repair.** `Chadcn::Theme.validate(palette, strict: true)`; for each failing pair move the foreground's L by `REPAIR_STEP` toward its candidate extreme (up to `REPAIR_MAX_STEPS`); if `primary-foreground/primary` still fails, move `primary.l` by 0.1 away from 0.5 once and redo the foreground; a palette that still fails returns the failures to the operation, which fails with `:contrast` and the list.

## Worked example

Input: `primary = oklch(0.55 0.20 250)` (a saturated blue), `tint = 0.5`, radius default.

| Variable | Light | Dark |
|---|---|---|
| `background` | `oklch(1 0 0)` | `oklch(0.141 0.008 250)` |
| `foreground` | `oklch(0.141 0.008 250)` | `oklch(0.985 0.008 250)` |
| `primary` | `oklch(0.55 0.2 250)` | `oklch(0.7 0.16 250)` |
| `primary-foreground` | `oklch(0.985 0 0)` (white wins: ~5.6:1) | `oklch(0.141 0.008 250)` (dark wins) |
| `secondary` | `oklch(0.967 0.008 250)` | `oklch(0.274 0.008 250)` |
| `muted-foreground` | `oklch(0.552 0.016 250)` | `oklch(0.705 0.015 250)` |
| `border` | `oklch(0.92 0.008 250)` | `oklch(1 0 0 / 10%)` |
| `ring` | `oklch(0.705 0.12 250)` | `oklch(0.552 0.12 250)` |
| `chart-1` … `chart-5` | hues 210, 230, 250, 270, 290 at L 0.65 C 0.2 | same hues at L 0.70 |
| `sidebar-primary` | = primary | = dark primary |
| `destructive` | `oklch(0.577 0.245 27.325)` | `oklch(0.704 0.191 22.216)` |
| `radius` | `0.625rem` | — |

The contrast figures above are illustrative; the test asserts them through `Chadcn::Theme.contrast`, not by hand.

## Why this shape

shadcn's own presets (neutral, gray, zinc, slate, stone) differ only in the hue and chroma of their neutrals and keep the same lightness steps; a colored theme on ui.shadcn.com keeps the neutrals and swaps the primary. Reproducing that structure is what makes a derived theme look like a shadcn theme instead of a rainbow. Hue-rotation harmonies (complementary, triadic) are a chart concern, not a surface concern, which is why they appear only in `chart-*`.
