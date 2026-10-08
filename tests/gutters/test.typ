#import "../../codly.typ" as codly
#import "../../src/gutter.typ" as impl
#import "@preview/elembic:1.1.1" as e

#set page(width: 320pt, height: auto, margin: 6pt)

// Constructors and casts retain data rather than folding arrays together.
#let column = codly.gutter-column(values: (none, "+", 12, [tag]))
#assert.eq(e.fields(column).values, (none, "+", 12, [tag]))
#let cast(value) = {
  let (ok, column) = e.types.cast(value, codly.gutter-column)
  assert(ok)
  e.fields(column)
}
#assert.eq(cast(("a", "b")).values, ("a", "b"))
#assert.eq(cast((values: (1,), align: left)).align, left)
#let callback = row => row.number
#assert.eq(cast(callback).values, callback)
#assert.eq(impl.columns(auto, true), (auto,))
#assert.eq(impl.columns(auto, false), ())
#assert.eq(impl.columns((auto, column), false), (e.fields(column),))
#assert.eq(impl.columns((), true), ())
#assert.eq(impl.value(e.fields(column), (kind: "code", source-line: 2)), "+")
#assert.eq(impl.value(e.fields(column), (kind: "code", source-line: 20)), none)
#assert.eq(impl.value(e.fields(column), (kind: "skip", source-line: none)), none)

#let callback-column = cast(row => if row.kind == "code" { row.text } else { [skip] })
#assert.eq(impl.value(callback-column, (kind: "code", text: "hello")), "hello")
#assert.eq(impl.value(callback-column, (kind: "skip", text: none)), [skip])
#assert(catch(() => impl.value(cast(_ => true), (kind: "code"))).contains("gutter values"))

#let row = (index: 0, kind: "code", source-line: 1, number: 10)
#let fills(fill) = impl.fills(
  (cast((values: (), fill: fill)),),
  (row,),
  (blue,),
  none,
  source: ("one",),
)
#assert.eq(fills(auto), ((blue,),))
#assert.eq(fills(none), ((none,),))
#assert.eq(fills(red), ((red,),))
#assert.eq(fills((red, green)), ((red,),))
#let gradient-fill = gradient.linear(red, blue)
#let tile-fill = tiling(size: (4pt, 4pt), rect(width: 2pt, height: 4pt, fill: aqua, stroke: none))
#assert.eq(repr(fills(gradient-fill)), repr(((gradient-fill,),)))
#assert.eq(repr(fills(tile-fill)), repr(((tile-fill,),)))
#let cycling-rows = range(4).map(index => (
  index: index,
  kind: if index == 3 { "skip" } else { "code" },
  source-line: if index == 3 { none } else { index + 1 },
  number: if index == 3 { none } else { index + 10 },
))
#assert.eq(
  repr(impl.fills(
    (cast((values: (), fill: (gradient-fill, none, tile-fill))),),
    cycling-rows,
    (blue,) * 4,
    none,
  )),
  repr(((gradient-fill, none, tile-fill, gradient-fill),)),
)
#assert.eq(
  fills(row => {
    assert.eq(row.text, "one")
    assert.eq(row.number, 10)
    green
  }),
  ((green,),),
)
#assert(catch(() => fills(())).contains("gutter fill palettes"))

// Exercise the real renderer: source arrays are not shifted by range/offset,
// unnumbered rows, synthetic skips, callouts, or header/footer rows.
#let observe(row) = [#metadata(row)<gutter-row>#if row.kind == "skip" { [s] } else {
    row.source-line
  }]
#show: codly.number-show_(it => {
  [#metadata(e.fields(it).number)<ordinary-number>#it]
})
#figure(caption: [Mapped gutters])[
  #codly.new(
    raw("first\nsecond\nthird\nfourth\nfifth", block: true),
    block-label: <mapped>,
    offset: 10,
    range: (2, 4),
    smart-skip: true,
    skips: ((3, 5),),
    unnumbered: ((3, [u]),),
    header: [header],
    footer: [footer],
    callouts: ((line: 2, body: [note]),),
    gutters: (
      auto,
      ("a", [#metadata("b")<array-value>b], "c", "d", "e"),
      (values: observe, align: center),
    ),
  )
]<mapped>
#context {
  let rows = query(<gutter-row>).map(it => it.value)
  assert.eq(rows.map(row => row.kind), ("skip", "code", "skip", "code", "code", "skip"))
  assert.eq(rows.map(row => row.index), (1, 2, 4, 5, 6, 7))
  assert.eq(rows.filter(row => row.kind == "code").map(row => row.source-line), (2, 3, 4))
  assert.eq(rows.filter(row => row.kind == "code").map(row => row.number), (12, none, 18))
  assert.eq(rows.filter(row => row.kind == "code").map(row => row.text), (
    "second",
    "third",
    "fourth",
  ))
  assert.eq(query(<array-value>).len(), 1)
  let numbers = query(<ordinary-number>).map(it => it.value)
  assert.eq(numbers.len(), 6)
  assert.eq(numbers.filter(n => type(n) == int), (12, 18))
  assert.eq(numbers.at(3), [u])
  assert.eq(numbers.at(0), numbers.at(2))
  assert.eq(numbers.at(0), numbers.at(5))
  assert.eq(codly.info(<mapped>), (last-number: 18, lines: 5))
  assert.eq(query(<mapped:12>).len(), 1)
  assert.eq(query(<mapped:l17p1>).len(), 1)
}

// Explicit custom gutters still render with ordinary numbering disabled.
#codly.new(raw("custom only", block: true), number-enabled: false, gutters: (
  auto,
  row => [#metadata(row)<custom-only>\*],
))
#codly.new(raw("no columns", block: true), gutters: ())
#context {
  assert.eq(query(<custom-only>).len(), 1)
  assert.eq(query(<ordinary-number>).len(), 6)
}

// Scoped configuration and explicit replacement do not concatenate arrays.
#{
  show: codly.set_(gutters: ((_ => [#metadata(1)<inherited-gutter>]),))
  codly.new(raw("inherited", block: true))
  codly.new(raw("replaced", block: true), gutters: ())
}
#context { assert.eq(query(<inherited-gutter>).len(), 1) }

// Styling is resolved on the real grid cells, including body-highlight
// inheritance and row-aware fills. Headers and callouts own their paints.
#{
  show grid.cell: it => {
    if it.fill in (red, green, orange, blue) {
      [#metadata((
          x: it.x,
          y: it.y,
          fill: it.fill,
          align: it.align,
          inset: it.inset,
          stroke: it.stroke,
        ))<styled-cell>#it]
    } else { it }
  }
  codly.new(
    raw("styled one\nstyled two", block: true),
    header: codly.header([header], fill: none),
    footer: codly.footer([footer], fill: none),
    callouts: ((line: 1, body: [callout]),),
    highlighted: ((2, blue),),
    gutters: (
      (values: ("a", "b"), fill: (red, green), align: center, inset: 2pt, stroke: purple + 1pt),
      (
        values: (),
        fill: row => {
          assert.eq(row.kind, "code")
          assert.eq(row.text, if row.source-line == 1 { "styled one" } else { "styled two" })
          orange
        },
      ),
      (values: (1, 2), fill: auto),
    ),
  )
}
#context {
  let cells = query(<styled-cell>).map(it => it.value)
  let first = cells.find(cell => cell.x == 0 and cell.y == 1)
  assert.eq(first.fill, green)
  assert.eq(first.align, center + horizon)
  assert.eq(first.inset, 0% + 2pt)
  assert.eq(first.stroke.paint, purple)
  assert.eq(cells.filter(cell => cell.x == 1).map(cell => cell.fill), (orange, orange))
  // The intervening callout occupies row 2; the second source row is row 3.
  assert.eq(cells.find(cell => cell.x == 0 and cell.y == 3).fill, green)
  assert.eq(cells.find(cell => cell.x == 2 and cell.y == 3).fill, blue)
}

// Flexible widths and arbitrary content/float values are valid too.
#codly.new(raw("flexible", block: true), gutters: (
  (values: (1.5,), width: 10%),
  (values: ([#box(fill: yellow)[badge]],), width: 1fr),
  (values: (), width: 0pt),
))

// Non-color paints also go through native and outside geometry rendering.
#for placement in ("inside", "outside") {
  show: codly.number-set_(placement: placement)
  codly.new(raw("gradient\npattern", block: true), gutters: (
    (values: ("G", "T"), fill: (gradient-fill, tile-fill)),
    (values: (1, 2), fill: gradient-fill),
    (values: (), fill: _ => tile-fill),
  ))
}
