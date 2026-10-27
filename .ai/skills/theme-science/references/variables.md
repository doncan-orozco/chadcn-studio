# The shadcn theme variables

Source of truth: `Chadcn::Theme::REQUIRED` (32 names, both modes) and `Chadcn::Theme::ROOT_ONLY` (`radius`). The values below are the gem's zinc preset, which the harmony rule reproduces when the primary is zinc's own primary and the tint is 0.4.

## Light (`:root`)

| Variable | Zinc value | Role |
|---|---|---|
| `background` | `oklch(1 0 0)` | page surface |
| `foreground` | `oklch(0.141 0.005 285.823)` | text on background |
| `card` / `card-foreground` | `oklch(1 0 0)` / `oklch(0.141 0.005 285.823)` | card surface and text |
| `popover` / `popover-foreground` | `oklch(1 0 0)` / `oklch(0.141 0.005 285.823)` | overlay surface and text |
| `primary` / `primary-foreground` | `oklch(0.21 0.006 285.885)` / `oklch(0.985 0 0)` | brand fill and text on it |
| `secondary` / `secondary-foreground` | `oklch(0.967 0.001 286.375)` / `oklch(0.21 0.006 285.885)` | quiet fill and text |
| `muted` / `muted-foreground` | `oklch(0.967 0.001 286.375)` / `oklch(0.552 0.016 285.938)` | de-emphasised fill and text |
| `accent` / `accent-foreground` | `oklch(0.967 0.001 286.375)` / `oklch(0.21 0.006 285.885)` | hover fill and text |
| `destructive` | `oklch(0.577 0.245 27.325)` | danger (fixed) |
| `border` / `input` | `oklch(0.92 0.004 286.32)` | lines and field borders |
| `ring` | `oklch(0.705 0.015 286.067)` | focus ring |
| `chart-1` … `chart-5` | `0.871 / 0.552 / 0.442 / 0.37 / 0.274` at `~0.006..0.017 286` | data series |
| `sidebar` / `sidebar-foreground` | `oklch(0.985 0 0)` / `oklch(0.141 0.005 285.823)` | sidebar surface and text |
| `sidebar-primary` / `sidebar-primary-foreground` | `oklch(0.21 0.006 285.885)` / `oklch(0.985 0 0)` | active item |
| `sidebar-accent` / `sidebar-accent-foreground` | `oklch(0.967 0.001 286.375)` / `oklch(0.21 0.006 285.885)` | hover item |
| `sidebar-border` / `sidebar-ring` | `oklch(0.92 0.004 286.32)` / `oklch(0.705 0.015 286.067)` | lines and focus |
| `radius` | `0.625rem` | corner radius; `tokens.css` derives `--radius-sm/md/lg/xl` from it |

## Dark (`.dark`)

| Variable | Zinc value |
|---|---|
| `background` / `foreground` | `oklch(0.141 0.005 285.823)` / `oklch(0.985 0 0)` |
| `card`, `popover` (and their foregrounds) | `oklch(0.21 0.006 285.885)` / `oklch(0.985 0 0)` |
| `primary` / `primary-foreground` | `oklch(0.92 0.004 286.32)` / `oklch(0.21 0.006 285.885)` |
| `secondary`, `muted`, `accent` | `oklch(0.274 0.006 286.033)` |
| `secondary-foreground`, `accent-foreground` | `oklch(0.985 0 0)` |
| `muted-foreground` | `oklch(0.705 0.015 286.067)` |
| `destructive` | `oklch(0.704 0.191 22.216)` (fixed) |
| `border` / `input` | `oklch(1 0 0 / 10%)` / `oklch(1 0 0 / 15%)` (alpha: contrast is not judged) |
| `ring` | `oklch(0.552 0.016 285.938)` |
| `chart-1` … `chart-5` | `0.871 / 0.552 / 0.442 / 0.37 / 0.274` |
| `sidebar` / `sidebar-foreground` | `oklch(0.21 0.006 285.885)` / `oklch(0.985 0 0)` |
| `sidebar-primary` / `sidebar-primary-foreground` | zinc ships a blue here (`oklch(0.488 0.243 264.376)`); the harmony rule uses the dark primary instead |
| `sidebar-accent` / `sidebar-accent-foreground` | `oklch(0.274 0.006 286.033)` / `oklch(0.985 0 0)` |
| `sidebar-border` / `sidebar-ring` | `oklch(1 0 0 / 10%)` / `oklch(0.552 0.016 285.938)` |

No `radius` in `.dark`.

## Text pairs the contrast check reads (`Chadcn::Theme::CONTRAST_PAIRS`, minimum 4.5:1)

`foreground/background`, `card-foreground/card`, `popover-foreground/popover`, `primary-foreground/primary`, `secondary-foreground/secondary`, `muted-foreground/muted`, `accent-foreground/accent`, `sidebar-foreground/sidebar`, `sidebar-primary-foreground/sidebar-primary`, `sidebar-accent-foreground/sidebar-accent`. A pair with an alpha color is skipped.

## oklch ranges the contract accepts

| Component | Range | Formatting |
|---|---|---|
| L (lightness) | 0 … 1 | three decimals, no `%` |
| C (chroma) | 0 … 0.4 | three decimals |
| H (hue) | 0 … 360 | three decimals, no `deg` |
| alpha | only `border`/`input` in dark | `/ 10%` style |

A hex or `hsl()` input is converted to oklch at the contract (one conversion, in Ruby); `Chadcn::Theme` accepts both when importing, but this app stores and exports oklch only, so a saved palette has one syntax.

## Values that cannot be saved

`Chadcn::Theme::UNSAFE_VALUE` rejects `/*`, `*/`, `{`, `}`, `;`, `\` and `url(` anywhere in a value: they could break out of the CSS block on import. A formatted oklch string never contains them; a value that does comes from outside and is refused by the contract and again by the validator.
