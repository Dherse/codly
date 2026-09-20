# GitHub review — 2026-09-16

Reviewed the current open issues and all seven open PRs against the development
element API. This document records local implementation state; upstream merge
and issue closure remain separate.
The [full issue roadmap](issue-roadmap.md) distinguishes confirmed fixes from
remaining bugs, supported workflows, and proposed features.

| PR | Result |
| --- | --- |
| [#103 — skip arrays](https://github.com/Dherse/codly/pull/103) | Adapted to the current line loop, addressing [#102](https://github.com/Dherse/codly/issues/102). `skip-line` and `skip-number` accept arrays. Duplicate skips consume one entry; smart skips use the last entry without consuming one. Empty arrays use the defaults, and `none` hides a marker. |
| [#123 — language radius](https://github.com/Dherse/codly/pull/123) | Added dictionary radii to `codly-lang` and the argument documentation. Kept the PR's unrelated filename removals out of the change. Tests check native box corners and per-language overrides. |
| [#132 — highlight baselines](https://github.com/Dherse/codly/pull/132) | The development branch's existing `0pt` default already aligns correctly on Typst 0.15.1. Preserved that default and added explicit `auto` support to the element and per-highlight options. Tests compare rendered positions for ordinary, padded and tagged highlights, plus explicit shifts. |
| [#115 — empty code](https://github.com/Dherse/codly/pull/115) | The unused calculation is already gone. Added a regression for empty code and its queried line information. |
| [#119 — unnumbered highlights](https://github.com/Dherse/codly/pull/119) | Already covered by the current shared grid fill callback. Added the reported reproduction. The PR's nested fallback lookup is redundant with its outer lookup. |
| [#114 — PDF/UA](https://github.com/Dherse/codly/pull/114) | Selective semantics are complete locally, but the PR is not merged. Follow-up fixes to the accessibility commit are implemented and tested: visible code stays outside hidden anchors, the brace is artifact-only, and annotation text remains accessible. PDF/UA-1 compilation plus extracted code/text were validated on Typst 0.15.1. |
| [#138 — outside rounding](https://github.com/Dherse/codly/pull/138) | The issue is addressed locally with an alternative in `src/geometry.typ`: one source-content grid plus queried cell bounds for decorative code-area clipping and matching stroke geometry, with no duplicate source grid or per-number measurement. The PR itself is not merged. |

Additional reproductions confirmed that the development API already handles
[#94](https://github.com/Dherse/codly/issues/94) (gradient headers),
[#106](https://github.com/Dherse/codly/issues/106) (unnumbered figure alignment),
[#110](https://github.com/Dherse/codly/issues/110) (final singleton smart skip),
[#118](https://github.com/Dherse/codly/issues/118) (unnumbered highlights),
[#129](https://github.com/Dherse/codly/issues/129) (icon-only badges),
[#135](https://github.com/Dherse/codly/issues/135) (removed `pattern` reference),
[#140](https://github.com/Dherse/codly/issues/140) (actual annotation row
spans including wrapping, ranges and skips; pagination preserves source lines), [#134](https://github.com/Dherse/codly/issues/134) and
[#139](https://github.com/Dherse/codly/issues/139) (outside code-area
geometry), [#107](https://github.com/Dherse/codly/issues/107) (half-stroke
margin reservation), and [#95](https://github.com/Dherse/codly/issues/95)
(relative-size alias handling). These cases now have regression coverage.

For aliases, inherited string theme and syntax paths work. Explicit raw
resource arguments must use caller-resolved `path("...")` or `read("...")`
values; plain strings now produce a diagnostic instead of being guessed
relative to the package ([#99](https://github.com/Dherse/codly/issues/99)).

```typ
#codly.new(raw("x", block: true, lang: "custom",
    theme: path("themes/dark.tmTheme"),
    syntaxes: (path("grammars/custom.sublime-syntax"),)),
  aliases: (custom: "python"),
)
```

Example using the development API:

```typ
#import "../codly.typ" as codly
#show: codly.lang-set_(radius: (top-left: 4pt, bottom-right: 4pt, rest: 0pt))
#codly.new(
  raw("one\ntwo\nthree\nfour", block: true),
  skips: ((2, 0), (4, 0)),
  skip-line: ([input], [output]),
  skip-number: ([in], [out]),
)
```

Skip-array selection uses a scalar counter in the existing pass, with no new
per-line closures, sorting or filtered arrays. Run `python3 tests/run.py` for the
full suite; the new fixtures use small pages and semantic assertions.

The current behavior was validated on Typst 0.15.1. The manifest still
declares Typst 0.12, so release compatibility needs an explicit decision and
metadata update. `path(...)` is available from [Typst 0.15](https://typst.app/docs/changelog/0.15.0/); older-compatible
explicit resources can use byte values from `read(..., encoding: none)`.
