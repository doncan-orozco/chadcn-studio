# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [1.0.0] - Unreleased

### Added
- Theme model with a palette validator, fixtures and seeds.
- Harmony derivation: a full light and dark shadcn palette from a primary color, tint, radius and optional overrides, in oklch.
- Preview pages (dashboard, form, landing, settings, auth, shell) and a components gallery rendered from `Chadcn::Catalog`.
- Themes list, create, show and delete.
- Editor with grouped dialogs, instant preview, a derivation endpoint and save.
- Publish and unpublish, CSS and JSON export, and the public URL `/t/<slug>.css|.json` that `chadcn:theme:import` consumes.
- Theme generation from a prompt with Claude through a Solid Queue job, delivered by Turbo Stream.
- README, as-built record and this changelog.
