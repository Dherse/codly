#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 160pt, height: auto, margin: 5pt)

// Keep the expected values as data so every constructor and cast follows the
// same assertion path. `e.fields` removes the implementation metadata from
// the comparison.
#let check-constructors(cases) = {
  for case in cases {
    assert.eq(e.fields(case.at(0)), case.at(1))
  }
}

#let check-casts(cases) = {
  for case in cases {
    let result = e.types.cast(case.at(1), case.at(0))
    assert.eq(result.at(0), true)
    assert.eq(e.fields(result.at(1)), case.at(2))
  }
}

#let default-numbering = numbering.with("(1)")

#check-constructors((
  // `language` and `smart-skip` take named fields.
  (codly.language(name: "Python"), (name: "Python", color: none, icon: none)),
  (
    codly.language(name: [Python], color: blue, icon: "py"),
    (name: [Python], color: blue, icon: "py"),
  ),
  (codly.smart-skip(), (first: none, last: none, rest: none)),
  (codly.smart-skip(first: true, last: false, rest: none), (first: true, last: false, rest: none)),

  // Pair-like constructors accept both positional and named required fields.
  (codly.range(2, 5), (start: 2, end: 5)),
  (codly.range(start: 3, end: none), (start: 3, end: none)),
  (codly.skip(4), (position: 4, length: 1)),
  (codly.skip(position: 5, length: 3), (position: 5, length: 3)),
  (codly.highlighted-line(6), (line: 6, color: none)),
  (codly.highlighted-line(line: 7, color: green), (line: 7, color: green)),

  // Optional values are retained, while omitted highlight bounds normalize.
  (
    codly.highlight(8),
    (
      line: 8,
      start: 0,
      end: 999999999,
      fill: none,
      tag: none,
      inset: none,
      baseline: none,
      clip: none,
      outset: none,
      radius: none,
      label: none,
      stroke: none,
      depth: none,
    ),
  ),
  (
    codly.highlight(
      9,
      start: 2,
      end: 6,
      fill: red,
      tag: "marked",
      inset: 1pt,
      baseline: 2pt,
      clip: true,
      outset: 3pt,
      radius: 4pt,
      depth: 5,
    ),
    (
      line: 9,
      start: 2,
      end: 6,
      fill: red,
      tag: "marked",
      inset: 1pt,
      baseline: 2pt,
      clip: true,
      outset: 3pt,
      radius: 4pt,
      label: none,
      stroke: none,
      depth: 5,
    ),
  ),
  (
    codly.highlight(10, start: none, end: none),
    (
      line: 10,
      start: 0,
      end: 999999999,
      fill: none,
      tag: none,
      inset: none,
      baseline: none,
      clip: none,
      outset: none,
      radius: none,
      label: none,
      stroke: none,
      depth: none,
    ),
  ),
  (
    codly.annotation(11),
    (
      start: 11,
      end: 11,
      content: none,
      label: none,
      numbering: default-numbering,
    ),
  ),
  (
    codly.annotation(12, end: 14, content: [explanation]),
    (
      start: 12,
      end: 14,
      content: [explanation],
      label: none,
      numbering: default-numbering,
    ),
  ),
))

#check-casts((
  // Dictionary and string casts for language preserve unknown fields.
  (
    codly.language,
    (name: "Rust", color: orange, icon: "rs", aliases: 2),
    (name: "Rust", color: orange, icon: "rs", aliases: 2),
  ),
  (codly.language, "Typst", (name: "Typst", color: none, icon: none)),

  // Bool and dictionary casts for smart skips fill omitted sides from `rest`.
  (codly.smart-skip, true, (first: true, last: true, rest: true)),
  (codly.smart-skip, (rest: true, first: false), (first: false, last: true, rest: true)),

  // Arrays and dictionaries both feed the pair-like constructors.
  (codly.range, (2, 4), (start: 2, end: 4)),
  (codly.range, (start: 3), (start: 3, end: none)),
  (codly.skip, (5, 2), (position: 5, length: 2)),
  (codly.skip, (position: 6), (position: 6, length: 1)),
  (codly.highlighted-line, 7, (line: 7, color: none)),
  (codly.highlighted-line, (8, purple), (line: 8, color: purple)),
  (codly.highlighted-line, (line: 9, color: teal), (line: 9, color: teal)),

  // Highlight and annotation dictionary casts retain supplied values and
  // apply the same defaults as their constructors.
  (
    codly.highlight,
    (line: 13, start: 1, end: 4, tag: "tag", clip: false, depth: 2),
    (
      line: 13,
      start: 1,
      end: 4,
      fill: none,
      tag: "tag",
      inset: none,
      baseline: none,
      clip: false,
      outset: none,
      radius: none,
      label: none,
      stroke: none,
      depth: 2,
    ),
  ),
  (
    codly.annotation,
    (start: 15, end: 16, content: [note]),
    (
      start: 15,
      end: 16,
      content: [note],
      label: none,
      numbering: default-numbering,
    ),
  ),
))

// Exercise the same casts through the public block constructor, where these
// types are consumed in arrays and option fields.
#let block-fields = e.fields(codly.new(
  none,
  range: (17, 19),
  smart-skip: true,
  skips: ((20, 2),),
  highlighted: (21,),
  highlights: ((line: 22, start: 1, end: 2),),
  annotations: ((start: 23, content: [note]),),
))

#assert.eq(e.fields(block-fields.range), (start: 17, end: 19))
#assert.eq(e.fields(block-fields.smart-skip), (first: true, last: true, rest: true))
#assert.eq(e.fields(block-fields.skips.at(0)), (position: 20, length: 2))
#assert.eq(e.fields(block-fields.highlighted.at(0)), (line: 21, color: none))
#assert.eq(e.fields(block-fields.highlights.at(0)), (
  line: 22,
  start: 1,
  end: 2,
  fill: none,
  tag: none,
  inset: none,
  baseline: none,
  clip: none,
  outset: none,
  radius: none,
  label: none,
  stroke: none,
  depth: none,
))
#assert.eq(e.fields(block-fields.annotations.at(0)), (
  start: 23,
  end: 23,
  content: [note],
  label: none,
  numbering: default-numbering,
))

// Failed casts report false without requiring the full diagnostic text.
#for (type, value) in (
  (codly.language, (color: red)), // missing required name
  (codly.range, "range"),
  (codly.skip, true),
  (codly.highlighted-line, "line"),
  (codly.highlight, false),
  (codly.annotation, 0),
) {
  assert.eq(e.types.cast(value, type).at(0), false)
}
