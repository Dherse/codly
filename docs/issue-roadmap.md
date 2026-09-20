# Open issue roadmap — 2026-09-20

The original GitHub audit covered 51 open issues and seven open PRs on
2026-09-15. Local implementation status was rechecked on 2026-09-20 against
`dev-v1.4.0` at `1485b36` and the pending changes. These are development-branch
findings, not a claim that a published v1.4.0 resolves them. The package
manifest still says 1.3.1; [Typst Universe](https://typst.app/universe/package/codly/)
listed 1.3.0 at the original audit.

All 18 confirmed fixes below are struck through. This includes local fixes
that have not been committed; it does not indicate GitHub issue closure.

- **Fixed by the pending changes:** ~~#140~~, ~~#139~~, ~~#134~~, ~~#107~~,
  ~~#95~~, ~~#99~~, and ~~#113~~. The resource limitation for #99 is recorded
  in its row below.
- **Already handled by committed code:** ~~#135~~, ~~#133~~, ~~#131~~,
  ~~#129~~, ~~#126~~, ~~#118~~, ~~#110~~, ~~#106~~, ~~#102~~, ~~#94~~,
  and ~~#91~~.

“Handled” means the reported behavior works in the current renderer, through an
existing regression or a targeted reproduction. It does not necessarily mean a
new patch was needed. “Supported” identifies an existing API or native Typst
route; it does not imply that every requested convenience API exists.
“Reproduced” means the problem still occurs. Other entries distinguish missing
features, partial support, and cases needing more evidence. Proposed work below
is a recommendation, not a commitment to ship every feature in v1.4.0.

Remaining priorities are reference formatting, number-column fill, badge
alignment, spacing, and compatibility documentation (#92/#127, #98, #112,
#125). Multilanguage blocks, paired listings and syntax-aware
transformations should be separate feature work.

Keep those changes within the existing preparation/layout passes where
possible: normalize spans once, pass small values to helpers, minimize captures,
and avoid repeated per-line measurements, sorting, or duplicate content grids.
Native references should continue to work without a required custom ref show
rule. Regression pages should use automatic height and small margins except
when fixed heights are needed to exercise pagination.

| Issue | Status | Current finding | Proposed next step |
| --- | --- | --- | --- |
| ~~[#140](https://github.com/Dherse/codly/issues/140)~~ | ~~Handled~~ | ~~Annotation geometry now uses the actual displayed row span, including wrapping, ranges and skips; pagination has a valid layout and preserves source lines. Annotation content is not repeated on continuation pages.~~ | ~~Keep the geometry regressions.~~ |
| ~~[#139](https://github.com/Dherse/codly/issues/139)~~ | ~~Handled~~ | ~~The new `src/geometry.typ` path uses queried code-cell bounds with one source-content grid for matching decorative clipping, without a duplicate source grid or per-number measurement.~~ | ~~Keep the outside-geometry regressions.~~ |
| [#137](https://github.com/Dherse/codly/issues/137) | Open; backend-dependent | No reliable exclusion of numbers from copying across PDF readers. | Try semantic line-number artifacts and validate extraction/readers; avoid promising universal nonselection. |
| ~~[#135](https://github.com/Dherse/codly/issues/135)~~ | ~~Handled~~ | ~~The obsolete pattern reference is gone; lang-fill:none is covered.~~ | ~~Keep the regression.~~ |
| ~~[#134](https://github.com/Dherse/codly/issues/134)~~ | ~~Handled~~ | ~~Outside-number code fills now follow the rounded code-area geometry from `src/geometry.typ`'s queried cell bounds and single source-content grid.~~ | ~~Keep large-radius, zebra-fill, range, header and pagination regressions.~~ |
| ~~[#133](https://github.com/Dherse/codly/issues/133)~~ | ~~Handled~~ | ~~The reported outer/inner highlight examples render with correct nesting, including shared ends.~~ | ~~Keep shared outer wrappers; promote the exact reproduction into the highlight regressions.~~ |
| ~~[#131](https://github.com/Dherse/codly/issues/131)~~ | ~~Handled~~ | ~~The existing 0pt default aligns correctly in the development renderer on Typst 0.15.1; explicit auto is now supported.~~ | ~~Keep measured baseline regressions; verify the release's supported Typst versions.~~ |
| [#130](https://github.com/Dherse/codly/issues/130) | Feature | Rainbow delimiter coloring is not implemented. | Consider an optional syntax-aware transformation that respects strings/comments; keep it out of the default rendering path. |
| ~~[#129](https://github.com/Dherse/codly/issues/129)~~ | ~~Handled~~ | ~~Icon-only badges render correctly.~~ | ~~Keep the language-style regression.~~ |
| [#128](https://github.com/Dherse/codly/issues/128) | Supported route | Typst raw accepts custom .sublime-syntax definitions. | Document and test the native syntaxes route; follow the explicit-resource compatibility rule in #99 for aliases. |
| [#127](https://github.com/Dherse/codly/issues/127) | Partial | Reference settings customize a shared separator/number suffix, not independent line/item formats. | Add small line/item formatter callbacks inside native figure numbering, preserving ordinary @ references. |
| ~~[#126](https://github.com/Dherse/codly/issues/126)~~ | ~~Handled in current API~~ | ~~A labelled figure with locally disabled numbers and right+top number alignment compiles.~~ | ~~Document translation from the old local(...) API and retain a focused regression.~~ |
| [#125](https://github.com/Dherse/codly/issues/125) | Partial / feature | Line insets can change spacing, but there is no dedicated leading control. | Expose explicit leading/row spacing and include it in annotation geometry; define wrapped-line behavior. |
| [#124](https://github.com/Dherse/codly/issues/124) | Supported | Scoped set rules restore settings correctly; no separate codly-local wrapper is needed. | Document scoped codly.set_ and element set rules with the current API. |
| [#122](https://github.com/Dherse/codly/issues/122) | Documentation / grammar | Language badges and syntax grammars are separate; adding a VBA badge does not add a grammar. | Check available language tags, then provide a custom VBA grammar example if needed. |
| [#121](https://github.com/Dherse/codly/issues/121) | Feature | Whitespace visualization is absent. | Add opt-in display decorations during existing line preparation, preserving source offsets and copied text. |
| ~~[#118](https://github.com/Dherse/codly/issues/118)~~ | ~~Handled~~ | ~~Whole-line highlights work with numbering disabled.~~ | ~~Keep the regression; PR #119 adds no needed fallback.~~ |
| [#117](https://github.com/Dherse/codly/issues/117) | Partial | Repeated headers exist; distinct first-page versus continuation wording does not. | Document repeat:true; investigate continuation-aware header content and default-inset clipping. |
| ~~[#113](https://github.com/Dherse/codly/issues/113)~~ | ~~Handled~~ | ~~Follow-up fixes to the accessibility commit are implemented and tested: visible code remains outside hidden anchors, the brace is an artifact only, and annotation text remains accessible. PDF/UA-1 compilation and extracted code/text were validated on Typst 0.15.1.~~ | ~~Keep the artifact semantics and validate reading order before release.~~ |
| [#112](https://github.com/Dherse/codly/issues/112) | Feature | Badge placement is hardcoded to right+horizon. | Add an alignment field read once per block; test a wrapping first line and headers. |
| [#111](https://github.com/Dherse/codly/issues/111) | Release work | Universe still advertises 1.3.0. | Publish the intended release through the package registry; verify manifest, tag, documentation and registry submission. |
| ~~[#110](https://github.com/Dherse/codly/issues/110)~~ | ~~Handled~~ | ~~A final single visible line receives the expected preceding smart skip.~~ | ~~Keep the singleton regression.~~ |
| [#109](https://github.com/Dherse/codly/issues/109) | Feature | The block/grid uses width:100%; intrinsic fit-to-content sizing is absent. | Add an explicit width mode; measure only when intrinsic sizing is requested and test wrapping and side-by-side blocks. |
| [#108](https://github.com/Dherse/codly/issues/108) | Partial; visual verification needed | Code, badge and highlight styling hooks are separate, but there is no complete dark-theme regression. | Add a real dark-theme fixture and recipe for foreground, badge text and highlight contrast; fix any inheritance failures it reveals. |
| ~~[#107](https://github.com/Dherse/codly/issues/107)~~ | ~~Handled with geometry caveat~~ | ~~The layout reserves half the resolved stroke width inside available bounds; borderless geometry is unchanged, while thick borders reduce inner width and increase height as required.~~ | ~~Keep margin and page-break regressions.~~ |
| ~~[#106](https://github.com/Dherse/codly/issues/106)~~ | ~~Handled~~ | ~~Disabled numbering with one-dimensional number alignment renders inside figures.~~ | ~~Keep the regression.~~ |
| [#105](https://github.com/Dherse/codly/issues/105) | Supported route | Native figure kinds and outline targets can produce a separate listings outline. | Add a tested recipe; a new Codly helper is optional. |
| [#104](https://github.com/Dherse/codly/issues/104) | Maintenance | Formatting is not enforced in CI. | Choose and pin a formatter, separate its initial formatting diff, then add fmt-check to CI. |
| ~~[#102](https://github.com/Dherse/codly/issues/102)~~ | ~~Handled~~ | ~~skip-line and skip-number accept arrays, including fallback and duplicate-skip behavior.~~ | ~~Keep the skip-formatting regressions; PR #103 was adapted.~~ |
| [#101](https://github.com/Dherse/codly/issues/101) | Supported route / optional feature | Native raw themes provide token colors; there is no Codly theme-preset registry. | Document themes plus separate foreground/block/badge styling; add bundled presets only if useful. |
| [#100](https://github.com/Dherse/codly/issues/100) | Release work | A repository version/tag does not make it available on Universe. | Resolve together with #111. |
| ~~[#99](https://github.com/Dherse/codly/issues/99)~~ | ~~Handled with compatibility caveat~~ | ~~Inherited string theme/syntax paths work. Explicit raw resource arguments must use `path(...)` or `read(...)`; plain strings now produce a diagnostic rather than being guessed relative to the package.~~ | ~~Document the resource rule and keep theme/syntax alias regressions.~~ |
| [#98](https://github.com/Dherse/codly/issues/98) | Partial / feature | Number show rules can style numeral boxes; full outside-gutter fill is absent. | Add a number-column fill setting to the existing grid fill callback. |
| [#97](https://github.com/Dherse/codly/issues/97) | Feature | Independent blocks do not synchronize wrapped row heights. | Design an explicit paired-listing/shared-row layout; avoid cross-block global state. |
| [#96](https://github.com/Dherse/codly/issues/96) | Feature | Character highlights target one line. | Normalize multiline spans once per block into per-line spans, with explicit tag/label ownership. |
| ~~[#95](https://github.com/Dherse/codly/issues/95)~~ | ~~Handled~~ | ~~Aliased raw blocks preserve the captured text size and do not apply relative text-size rules a second time.~~ | ~~Keep the relative-size alias regression.~~ |
| ~~[#94](https://github.com/Dherse/codly/issues/94)~~ | ~~Handled~~ | ~~Gradient fill with a header compiles through the shared native grid.~~ | ~~Keep the regression.~~ |
| [#93](https://github.com/Dherse/codly/issues/93) | Unverified | The report depends on a larger template; the provided imports are insufficient to reproduce it faithfully. | Reduce a current-API integration example and identify which show rule overrides Codly before claiming a fix. |
| [#92](https://github.com/Dherse/codly/issues/92) | Partial | The generated reference always includes the parent figure reference. | Add a whole-reference formatter so users can emit Line 1; keep native references and capture only required fields. |
| ~~[#91](https://github.com/Dherse/codly/issues/91)~~ | ~~Handled~~ | ~~A terminal empty line is omitted and the outside bottom border follows displayed rows.~~ | ~~Keep the trailing-newline, range and outside-geometry regressions.~~ |
| [#84](https://github.com/Dherse/codly/issues/84) | Feature / native recipe | Inline raw bypasses Codly's block renderer. | Document a native inline raw box rule; consider a separate lightweight inline helper. |
| [#83](https://github.com/Dherse/codly/issues/83) | Supported manually | A codly-number show rule can hide chosen numbers while retaining their code lines; tested for lines 1 and 3. | Document the hook; source-text predicates or automatic renumbering would be a separate addition. |
| [#80](https://github.com/Dherse/codly/issues/80) | Host/backend feature | A static PDF code block has no portable clipboard-button behavior. | Document output limitations; consider host/HTML integration or a source attachment. |
| [#72](https://github.com/Dherse/codly/issues/72) | Partial / feature | Highlight tags and side annotations cover some callout use cases, but dedicated inline callouts are absent. | Define marker placement and numbering semantics before adding a compact callout API. |
| [#70](https://github.com/Dherse/codly/issues/70) | Open; backend-dependent | Copy-only-code is not guaranteed. | Evaluate semantic artifacts for numbers/decorations without hiding meaningful annotations; test actual readers and extraction. |
| [#67](https://github.com/Dherse/codly/issues/67) | Unverified; regression needed | Custom raw/regex show behavior is not verified preserved through the current renderer. | Add paired labelled/unlabelled custom-language regressions, then fix any loss of user styling through the raw transformation. |
| [#66](https://github.com/Dherse/codly/issues/66) | Supported manually / feature | A header can display a filename; no dedicated filename component is present. | Document the header recipe, then consider a small badge/header convenience element. |
| [#64](https://github.com/Dherse/codly/issues/64) | Feature | Indentation guides are absent. | Draw opt-in guides from leading-whitespace data; define tabs and continuation-line behavior. |
| [#58](https://github.com/Dherse/codly/issues/58) | Feature | The documentation has local example helpers, but no public codly-example. | Extract a helper accepting explicit source and rendered content if the API is worth maintaining. |
| [#54](https://github.com/Dherse/codly/issues/54) | Deferred feature | There is no reliable native wrap-event hook for a continuation symbol. | Investigate native wrapping support first; avoid recreating the whole wrapping engine for this option. |
| [#46](https://github.com/Dherse/codly/issues/46) | Larger feature | A block currently has one syntax language. | Design language segments while preserving shared numbering, spans and references; keep this separate from release bug fixes. |

All seven open PRs have also been assessed. Local completion described here does
not imply an upstream merge or issue closure.

| PR | Current assessment |
| --- | --- |
| [#103](https://github.com/Dherse/codly/pull/103) | Skip arrays adapted to the current loop; #102 is covered by regressions. |
| [#123](https://github.com/Dherse/codly/pull/123) | Dictionary language-badge radii adapted and tested; unrelated filename removals excluded. |
| [#132](https://github.com/Dherse/codly/pull/132) | Explicit auto baseline support adapted. The current 0pt default already aligns, so no blanket default change was needed. |
| [#115](https://github.com/Dherse/codly/pull/115) | The obsolete calculation is already removed; empty-block behavior has a regression. |
| [#119](https://github.com/Dherse/codly/pull/119) | The shared grid callback already handles #118. The proposed nested fallback repeats the outer lookup and adds no needed behavior. |
| [#114](https://github.com/Dherse/codly/pull/114) | Selective semantics are complete locally, but the PR is not merged. Keep visible code outside hidden native line anchors, make the brace artifact-only, and retain accessible annotation text. |
| [#138](https://github.com/Dherse/codly/pull/138) | The issue is addressed locally with an alternative in `src/geometry.typ`: one source-content grid plus queried cell bounds for decorative code-area clipping and stroke geometry, with no duplicate source grid or per-number measurement. The PR itself is not merged. |

Evidence and limits: targeted reproductions confirmed nested highlights (#133),
terminal-newline handling (#91), manual number suppression (#83), the
current-API figure case (#126), actual annotation row spans including wrapping,
ranges and skips (#140), outside code-area geometry (#134/#139), margin
reservation (#107), and alias text-size handling (#95). Pagination has a valid
layout and preserves source lines; annotation content is not repeated on
continuation pages. Inherited string theme/syntax paths work for aliases; explicit
raw resource arguments must use `path(...)` or `read(...)`, and plain strings
now produce a diagnostic (#99). Reference, element, layout and pagination test
groups were rerun successfully during this review.

A 1,000-line Rust cold-compilation check (median of three processes per case)
compared `1485b36` with these changes: inside numbering took 5.04s versus 5.05s;
outside numbering took 5.05s versus 5.92s. Correct outside clipping currently
adds about 17% in that fixture. The geometry path retains one source grid and
uses small location keys for queried data; it does not measure each source line.

Follow-up fixes to the accessibility commit are implemented and tested:
visible code stays outside hidden native line anchors, the
annotation brace is artifact-only, and annotation text remains accessible.
PDF/UA-1 compilation plus extracted code and text were validated on Typst
0.15.1. Reading order on older compilers remains a release check.

The native [raw documentation](https://typst.app/docs/reference/text/raw/)
supports the custom-syntax/theme routes above; a theme supplies token colors,
while general foreground/background styling must be configured separately.
The [artifact documentation](https://typst.app/docs/reference/pdf/artifact/)
provides semantic kinds such as line-number and explains effects on extraction
and assistive technology. This is worth testing for #70/#137, but does not
guarantee identical selection behavior across PDF readers. The upstream
[nonselectable-text request](https://github.com/typst/typst/issues/2249) and
[manual syntax-highlighting request](https://github.com/typst/typst/issues/6635)
are relevant to copy behavior and alias handling respectively.

For aliases, use caller-resolved resources when passing an explicit theme or
syntax file:

```typ
#codly.new(raw("x", block: true, lang: "custom",
    theme: path("themes/dark.tmTheme"),
    syntaxes: (path("grammars/custom.sublime-syntax"),)),
  aliases: (custom: "python"),
)
```

The current behavior was validated on Typst 0.15.1. The manifest still
declares Typst 0.12, so release compatibility needs an explicit decision and
metadata update. `path(...)` is available from [Typst 0.15](https://typst.app/docs/changelog/0.15.0/); older-compatible
explicit resources can use byte values from `read(..., encoding: none)`.

See [the earlier PR review](github-review.md) for implementation details and the
skip-array example.
