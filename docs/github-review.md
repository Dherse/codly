# GitHub review — 2026-09-15

Reviewed the current open issues and all seven open PRs against the development
element API. Changes below are implemented locally; GitHub statuses are unchanged.

| PR | Result |
| --- | --- |
| [#103 — skip arrays](https://github.com/Dherse/codly/pull/103) | Adapted to the current line loop, addressing [#102](https://github.com/Dherse/codly/issues/102). `skip-line` and `skip-number` accept arrays. Duplicate skips consume one entry; smart skips use the last entry without consuming one. Empty arrays use the defaults, and `none` hides a marker. |
| [#123 — language radius](https://github.com/Dherse/codly/pull/123) | Added dictionary radii to `codly-lang` and the argument documentation. Kept the PR's unrelated filename removals out of the change. Tests check native box corners and per-language overrides. |
| [#132 — highlight baselines](https://github.com/Dherse/codly/pull/132) | The development branch's existing `0pt` default already aligns correctly on Typst 0.15.1. Preserved that default and added explicit `auto` support to the element and per-highlight options. Tests compare rendered positions for ordinary, padded and tagged highlights, plus explicit shifts. |
| [#115 — empty code](https://github.com/Dherse/codly/pull/115) | The unused calculation is already gone. Added a regression for empty code and its queried line information. |
| [#119 — unnumbered highlights](https://github.com/Dherse/codly/pull/119) | Already covered by the current shared grid fill callback. Added the reported reproduction. The PR's nested fallback lookup is redundant with its outer lookup. |
| [#114 — PDF/UA](https://github.com/Dherse/codly/pull/114) | Needs a selective rewrite and PDF/UA validation. Wrapping visible line-reference figures in `pdf.artifact` would also hide their source code from assistive technology. Hidden reference helpers and decorative icons can be considered separately. |
| [#138 — outside rounding](https://github.com/Dherse/codly/pull/138) | Needs a different implementation for this branch. The PR measures each number and builds a second grid from raw lines; that adds work and does not track displayed ranges, skips and annotations. It also intentionally leaves the border problem in [#139](https://github.com/Dherse/codly/issues/139) unresolved. |

Additional reproductions confirmed that the development API already handles
[#94](https://github.com/Dherse/codly/issues/94) (gradient headers),
[#106](https://github.com/Dherse/codly/issues/106) (unnumbered figure alignment),
[#110](https://github.com/Dherse/codly/issues/110) (final singleton smart skip),
[#118](https://github.com/Dherse/codly/issues/118) (unnumbered highlights),
[#129](https://github.com/Dherse/codly/issues/129) (icon-only badges), and
[#135](https://github.com/Dherse/codly/issues/135) (removed `pattern` reference).
These cases now have regression coverage.

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
