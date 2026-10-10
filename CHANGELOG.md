# Changelog

## Unreleased — 2.0.0

### Breaking changes

- Require Typst 0.15.0 or newer.
- Rewrite the API using Elembic components. `codly.new(body, ...)` constructs
  a block; `#show: codly.set_(...)` sets scoped defaults.
- Remove `codly-init`, stateful configuration helpers, and `codly.enabled`.
  Automatic conversion uses `#show raw.where(block: true): codly.new`.
- Export unprefixed component names: `line`, `header`, `footer`, `lang`, `file`,
  `highlight`, `annotation`, `callout`, `bubble`, `number`, and reference
  components. Keep their internal `codly-...` selector identities.
- Move component styling to dedicated `*-set_` and `*-show_` rules. Move
  language definitions to `lang-set_(languages: ...)`, numbering to
  `number-set_(numbering: ...)`, and highlight defaults to `highlight-set_`.
- Replace zebra-specific fill settings with `line-set_(fill: ...)`.
- Replace `offset-from` and offset helper functions with `offset`: an integer,
  a block/figure label, or `auto`.

### Added

- `theme`, `define-theme`, and six presets: `thesis`, `dark`, `clean`,
  `github-light`, `solarized-light`, and `one-light`.
- Five-color highlight palettes per theme. Whole-row and span highlights cycle
  independently; explicitly colored highlights do not consume palette entries.
- Row fills accepting a paint, cycling array, or row callback. Number-column
  `fill: auto` follows the code row; header/footer fills remain independent.
- `gutter-column` and `gutters` for multiple independently styled columns.
  Values accept source-aligned arrays or row callbacks; `auto` includes ordinary
  numbering, and `()` hides all gutters. Support outside placement and pagination.
- Automatic `diff,<language>` highlighting with separate old/new syntax passes,
  marker-free source, old/new numbering, and change markers. Support unified
  hunks, simple fragments, configurable paints, and custom gutters.
- Plain callout rows attached to source lines, above or below the code.
- Pointed callout bubbles with character anchors, configurable paint, border,
  width, alignment, and pointer geometry. Pack noncolliding bubbles into lanes.
- Optional source-indented plain callouts.
- Literal source strings and caller-resolved file paths as block inputs.
  Infer language and filename from paths; allow explicit overrides.
- A dedicated filename component. Position filename and language badges in
  header/footer bands or beside the first code row.
- `width` accepting lengths, ratios, or `auto` for intrinsic code width.
- `padding` for block edges; independent `leading`, `gutter`, `column-gutter`,
  and `row-gutter` controls.
- Syntax-aware rainbow delimiters with configurable palettes; ignore delimiters
  in strings and comments.
- Indentation guides with automatic or explicit indent width, blank-line
  handling, and optional rainbow colors.
- `wrap-marker` for smart-indented continuation rows.
- `sublangs` for syntax-highlighted source ranges using the same line renderer,
  including ranges, skips, numbering, annotations, and highlights.
- `unnumbered` for hiding selected line numbers or replacing them with content.
- Native line, highlight, and annotation references with independent formatting,
  separators, numbering, and link targets.
- `codly.info(label)` returning source-line count and last displayed number.
- `offset: auto` anchoring excerpts at one; label offsets continue another
  block's last displayed number. Disjoint excerpts retain numbering gaps.
- Array-based `skip-line` and `skip-number` formatting.
- Per-language corner-radius dictionaries and icon alignment.
- Highlight `baseline: auto` for native content-baseline alignment.

### Fixed

- Infer native listing figure kinds for `codly.new`; preserve listing counters,
  captions, outlines, references, and explicit kind overrides.
- Preserve nesting for overlapping and equal-span highlights; split crossing
  spans without duplicating shared wrappers.
- Preserve highlight alignment and smart indentation across wrapped source;
  account for highlight insets when detecting continuation rows.
- Keep source text, trailing punctuation, empty lines, and tab-expanded character
  positions intact through syntax and highlight passes.
- Correct annotation brace geometry, overlap detection, and labeled references.
- Clip rounded code fills correctly with outside number columns.
- Keep row and custom-gutter highlights when ordinary numbers are disabled.
- Accept numbering strings and `none`; handle empty blocks and large offsets.
- Fit filename/language badges without unintended wrapping or overlap.
- Keep inherited body palettes out of header/footer paints and respect explicit
  component fill overrides.
- Preserve caller-relative syntax/theme resources when re-highlighting aliases
  and diffs; reject unsafe copied string paths.
- Apply theme scalar paints and highlight palettes correctly; reject empty
  palettes and unknown theme settings.
- Preserve PDF/UA structure and extractable source text through annotations,
  callouts, gutters, and diffs; avoid duplicate text from old/new syntax passes.

### Tooling

- Add behavioral and visual regressions, deferred-layout diagnostics, PDF/UA
  text-extraction checks, and Typst 0.15.0/0.15.1 compatibility jobs.
- Exclude development assets from packages and smoke-test isolated versioned
  imports. Validate the tagged commit before registry publication.
- Add Typst formatting checks; remove the legacy signature generator and
  bundled v1 manual.

### Contributors

[@Dherse](https://github.com/Dherse),
[@GeronimoCastano](https://github.com/GeronimoCastano),
[@rctsang](https://github.com/rctsang),
[@PhotonQuantum](https://github.com/PhotonQuantum),
[@RobbeDGreef](https://github.com/RobbeDGreef),
[@ha5ch](https://github.com/ha5ch),
[@Andrew15-5](https://github.com/Andrew15-5), and
[@youssefadly237](https://github.com/youssefadly237).

Discussion and review: [@JTrenerry](https://github.com/JTrenerry) and
[@PuddingisPOG](https://github.com/PuddingisPOG).

## 1.3.1 — 2025-08-06 - Never properly released

- Add per-highlight style overrides and improve nested highlights.
- Fix tagged highlight insets, annotation handling, and row fills when line
  numbers are disabled.
- Fix language-icon padding with hidden names and improve resilience to
  external set rules.
- Contributors: [@Dherse](https://github.com/Dherse), [@KoviRobi](https://github.com/KoviRobi),
  [@WaffleLapkin](https://github.com/WaffleLapkin), and
  [@t1mlange](https://github.com/t1mlange).

## 1.3.0 — 2025-03-28

- Support Typst 0.13 and migrate tests to Tytanic.
- Add outside line numbers, whole-line highlights, aliases, and `yes-codly`.
- Improve rendering performance, contextual callbacks, annotation placement,
  and language badges around skips.
- Contributors: [@Dherse](https://github.com/Dherse) and [@pmudry](https://github.com/pmudry).
  Thanks to [@ecomaikgolf](https://github.com/ecomaikgolf) for Typst 0.13
  compatibility contributions.

## 1.2.0 — 2024-12-29

- Standardize on one-based indexing and add smart skips.
- Add highlight clipping and outset controls.
- Fix skip reset behavior, skips without numbers, and missing block labels;
  improve references in preparation for Typst 0.13.
- Contributors: [@Dherse](https://github.com/Dherse) and [@KoviRobi](https://github.com/KoviRobi).

## 1.1.1 — 2024-12-04

- Add `skip-last-empty`, update the minimum compiler, and fix reference and
  documentation issues.
- Correct font licensing and documentation imports.
- Contributors: [@Dherse](https://github.com/Dherse) and [@Aaron-Rumpler](https://github.com/Aaron-Rumpler).

## 1.1.0 — 2024-12-01

- Adopt native `raw.line` rendering; add headers, footers, multiple ranges,
  and a Typst language icon.
- Improve references, local/nested configuration, highlight handling, smart
  indentation, and rendering performance.
- Contributors: [@Dherse](https://github.com/Dherse), [@JohnMeyerhoff23](https://github.com/JohnMeyerhoff23), and
  [@Aaron-Rumpler](https://github.com/Aaron-Rumpler).

## 1.0.0 — 2024-07-16

- First stable release of configurable code presentation, including smart
  indentation, line numbers, partial highlights, annotations, and references.
- Contributors to this release and its pre-1.0 history: [@Dherse](https://github.com/Dherse),
  [@Zheoni](https://github.com/Zheoni),
  [@PgBiel](https://github.com/PgBiel),
  [@kianmeng](https://github.com/kianmeng),
  [@domoritz](https://github.com/domoritz),
  [@drupol](https://github.com/drupol),
  [@hbierlee](https://github.com/hbierlee), and
  [@k4zuy](https://github.com/k4zuy).
- Thanks to [@sergio-fferreira](https://github.com/sergio-fferreira) for language
  spacing contributions and [@v-nxe](https://github.com/v-nxe) for feature proposals.
