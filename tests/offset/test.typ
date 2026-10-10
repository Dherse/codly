#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 300pt, height: auto, margin: 8pt)
#let source = raw("one\ntwo\nthree\nfour\nfive\nsix", block: true)
#for value in (0, -3, auto, <parent>) {
  assert.eq(e.fields(codly.new(source, offset: value)).offset, value)
}
#context {
  for value in (none, false, "auto", 1.5, 3pt, (1, 2)) {
    let error = catch(() => measure(codly.new(source, offset: value)))
    assert(error != none, message: "accepted invalid offset: " + repr(value))
  }
}
#let check(name, expected, ..options) = {
  let marker = label(name)
  show: codly.number-show_(it => [#metadata(e.fields(it).number)#marker#it])
  codly.new(source, ..options.named())
  context {
    assert.eq(query(marker).map(it => it.value), expected, message: name)
  }
}

// Existing defaults, explicit offsets, inclusive/open ranges, and no ranges.
#check("preserved", (3, 4, 5), range: (3, 5))
#check("reset", (1, 2, 3), range: (3, 5), offset: auto)
#check("positive", (13, 14, 15), range: (3, 5), offset: 10)
#{
  show: codly.number-set_(numbering: n => str(n))
  check("negative", (-1, 0, 1), range: (3, 5), offset: -4)
}
#check("open", (1, 2, 3, 4), range: (3,), offset: auto)
#check("whole", (1, 2, 3, 4, 5, 6), offset: auto)
#check("empty-ranges", (1, 2, 3, 4, 5, 6), ranges: (), offset: auto)
#check("no-match", (), range: (20,), offset: auto)
#check("before-source", (1, 2, 3), range: (-4, 3), offset: auto)

// Sorting/merging uses the earliest real source row; gaps are retained.
#check("disjoint", (1, 2, 4, 5), ranges: ((5, 6), (2, 3)), offset: auto)
#check("overlap", (1, 2, 3, 4, 5), ranges: ((4, 6), (2, 4)), offset: auto)
#check("empty-leading", (1, 2), ranges: ((-4, -2), (5, 6)), offset: auto)

// Set rules can be overridden per block without leaking to the next scope.
#{
  show: codly.set_(offset: auto)
  check("inherited", (1, 2), range: (4, 5))
  check("override", (4, 5), range: (4, 5), offset: 0)
}
#check("after-scope", (4, 5), range: (4, 5))

// Number-disabled blocks still expose adjusted metadata for continuation.
#codly.new(source, range: (3, 4), offset: auto, number-enabled: false)<hidden>
#codly.new(source, range: (3, 4), offset: <hidden>)<continued>
#codly.new(raw("next", block: true), offset: <continued>)<chained>
#context {
  // Additional arithmetic is explicit rather than a second offset field.
  [#codly.new(raw("shifted", block: true), offset: codly.info(<hidden>).last-number + 10)<shifted>]
}
#context {
  assert.eq(codly.info(<hidden>), (last-number: 2, lines: 6))
  assert.eq(codly.info(<continued>), (last-number: 6, lines: 6))
  assert.eq(codly.info(<chained>), (last-number: 7, lines: 1))
  assert.eq(codly.info(<shifted>), (last-number: 13, lines: 1))
}

// Source-addressed gutters/callouts/sublanguages stay on their original lines;
// inline highlights and typed references retain displayed-number semantics.
#figure(caption: [Reset numbering])[
  #codly.new(
    source,
    range: (3, 4),
    offset: auto,
    block-label: <reset-code>,
    sublangs: ((start: 3, end: 4, lang: "py"),),
    gutters: (auto, (values: row => [#metadata(row)<reset-gutter>#row.source-line])),
    callouts: ((line: 3, body: [#metadata("note")<reset-note>Source line three.]),),
    highlights: ((line: 1, tag: "reset", label: <reset-span>),),
    highlighted: (1,),
  )
]<reset-code>
#context {
  let rows = query(<reset-gutter>).map(it => it.value)
  assert.eq(rows.map(it => it.source-line), (3, 4))
  assert.eq(rows.map(it => it.number), (1, 2))
  assert.eq(rows.map(it => it.text), ("three", "four"))
  assert.eq(query(<reset-note>).len(), 1)
  assert.eq(query(<reset-code:1>).len(), 1)
  assert.eq(query(<reset-code:2>).len(), 1)
  assert.eq(query(<reset-span>).len(), 1)
  assert.eq(codly.info(<reset-code>), (last-number: 2, lines: 6))
}

// Synthetic skips remain additive; unnumbered rows retain their old policy.
#check(
  "skip",
  (1, [2], 4, 5),
  range: (3, 5),
  offset: auto,
  skips: ((4, 2),),
  skip-number: [2],
)
#check("unnumbered", (1, [u], 2), range: (3, 5), offset: auto, unnumbered: ((4, [u]),))
