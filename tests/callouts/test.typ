#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 250pt, height: auto, margin: 5pt)

#let text-of(body) = {
  if type(body) == str { body } else if body.has("text") { body.text } else if body.has(
    "children",
  ) { body.children.map(text-of).join() } else { "" }
}

// The public type uses `body`, exposes the cell fields directly, and validates
// its one-indexed source-line anchor.
#let fields = e.fields(codly.callout(
  line: 2,
  body: [Explanation],
  fill: yellow,
  inset: 3pt,
  pointer: 2,
  pointer-align: "end",
))
#assert.eq(
  (
    fields.line,
    text-of(fields.body),
    fields.fill,
    fields.inset,
    fields.pointer,
    fields.at("pointer-align"),
  ),
  (
    2,
    "Explanation",
    yellow,
    3pt,
    2,
    "end",
  ),
)

#show: codly.callout-show_(it => {
  let fields = e.fields(it)
  [#metadata((line: fields.line, body: text-of(fields.body)))<callout-row>#it]
})
#show grid.cell: it => {
  if it.rowspan > 1 { [#metadata(it.rowspan)<annotation-rowspan>#it] } else { it }
}

// Element settings provide the defaults for a callout cell; explicit entry
// fields override them. Numbered callouts span the number column, and two
// entries on a line retain source order.
#metadata("numbered")<numbered-case>
#{
  show: codly.callout-set_(fill: rgb("e5f2ff"), inset: (x: 8pt, y: 3pt), stroke: blue)
  codly.new(
    raw("one\ntwo\nthree", block: true, lang: "rs"),
    callouts: (
      (line: 1, body: [element defaults]),
      (line: 2, body: [local fill override], fill: rgb("fff0d6"), align: center),
      (line: 2, body: [local none override], fill: none, align: center),
    ),
  )
}

// Without line numbers, the callout is the only primary-grid cell and spans
// the entire block width.
#metadata("unnumbered")<unnumbered-case>
#codly.new(
  raw("alpha\nbeta", block: true),
  number-enabled: false,
  callouts: ((line: 1, body: [full-width unnumbered callout], fill: aqua),),
)

// A completed annotation leaves its final column available, so the following
// callout spans both the code and former annotation columns.
#metadata("annotation-before")<annotation-before-case>
#codly.new(
  raw("before\nafter\nend", block: true),
  annotations: ((start: 1, end: 1, content: [before]),),
  callouts: ((line: 2, body: [spans the inactive annotation column], fill: lime),),
)

// A callout inside a multi-line annotation preserves the final brace column,
// contributes a visual row to the annotation span, and may itself have a
// multi-line body.
#metadata("annotation-spans-numbered")<annotation-spans-numbered-case>
#codly.new(
  raw("first\nsecond\nthird", block: true),
  annotations: ((start: 1, end: 3, content: [numbered brace]),),
  callouts: (
    (
      line: 2,
      body: [first paragraph#linebreak()second paragraph],
      fill: rgb("ffe0e6"),
      inset: 4pt,
      breakable: true,
    ),
  ),
)

// The same active-annotation rule applies when the number column is absent.
#metadata("annotation-spans-unnumbered")<annotation-spans-unnumbered-case>
#codly.new(
  raw("red\ngreen", block: true),
  number-enabled: false,
  annotations: ((start: 1, end: 2, content: [unnumbered brace]),),
  callouts: ((line: 1, body: [keeps brace column], fill: purple.lighten(80%)),),
)

// An omitted source line has no callout after range filtering.
#metadata("range")<range-case>
#codly.new(
  raw("hidden\nshown", block: true),
  range: (2,),
  callouts: ((line: 1, body: [not shown]), (line: 2, body: [shown])),
)

#context {
  assert.eq(query(<callout-row>).map(it => it.value), (
    (line: 1, body: "element defaults"),
    (line: 2, body: "local fill override"),
    (line: 2, body: "local none override"),
    (line: 1, body: "full-width unnumbered callout"),
    (line: 2, body: "spans the inactive annotation column"),
    (line: 2, body: "first paragraphsecond paragraph"),
    (line: 1, body: "keeps brace column"),
    (line: 2, body: "shown"),
  ))
  // One active annotation has three source rows plus its callout; the other
  // has two source rows plus its callout.
  assert.eq(query(<annotation-rowspan>).map(it => it.value), (4, 3))
}
