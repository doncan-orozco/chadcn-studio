# chadcn studio

A theme builder for [chadcn](https://github.com/doncan-orozco/chadcn), the shadcn/ui design system ported to Phlex. It works like a
character creator: you pick one thing (a primary color), the app derives everything else (surfaces, text, borders, charts, sidebar,
dark mode) by a harmony rule, and you see the result at once on real pages built with the gem's own components. Tune by group, or
describe the look to Claude, then export a shadcn-format theme and import it into any chadcn app with one command.

## Walkthrough

1. **Create.** Themes -> New: give a name and a primary color (`oklch(0.55 0.2 250)`). The app derives a full light and dark palette
   and checks it with `Chadcn::Theme` (format, completeness, contrast); contrast is repaired where it can be, rejected where not.
2. **Tune.** The editor has a sidebar of groups (brand, surfaces and text, radius, charts, sidebar, dark mode, advanced). Each opens a
   dialog; changes preview instantly on the dashboard, form, landing, settings, auth and shell pages. Advanced pins a single variable
   and the rest keep following the rule. Save stores it.
3. **Generate.** The prompt panel asks Claude (`claude-opus-5-5`) for a theme from a description. It returns only a few palette
   inputs; the same derivation and validation run before anything is saved. Status arrives by Turbo Stream.
4. **Export.** Publish the theme to get a public URL, or download it from the Export dialog:
   - `GET /t/<slug>.css`: the shadcn `theme.css` colors section
   - `GET /t/<slug>.json`: name, slug, inputs and both palettes
5. **Import** into a chadcn app:

   ```bash
   bin/rails theme:import[https://<host>/t/<slug>.css]
   ```

The components gallery (`/gallery`) renders every component of `Chadcn::Catalog` with the current theme.

## Setup

Requires Ruby 4.0 and SQLite. The Gemfile takes `chadcn` from GitHub; for gem development point Bundler at a sibling checkout
(`bundle config set local.chadcn ../chadcn`).

```bash
bin/setup                              # install dependencies, prepare the database
export ANTHROPIC_API_KEY=sk-ant-...    # only needed for "generate from a prompt"
bin/dev                                # server + Tailwind watcher
```

Everything except generation works without the key.

## Commands

```bash
bin/ci                                  # the Gate: rubocop, audits, brakeman, tests, seeds
bin/rubocop
bin/rails test                          # bin/rails test path_test.rb:LINE for one
bin/rails test:system                   # Capybara + Cuprite
bin/rails chadcn:doctor                 # the gem's integration checks
```

## Contributing

Architecture, conventions and the epic workflow are in [CLAUDE.md](CLAUDE.md) and `.ai/skills/`. What was decided while building v1
is in [docs/features/theme-builder-v1/AS_BUILT.md](docs/features/theme-builder-v1/AS_BUILT.md). Changes are listed in
[CHANGELOG.md](CHANGELOG.md).
