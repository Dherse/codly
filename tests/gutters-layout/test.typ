#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 330pt, height: auto, margin: 8pt)
#set text(size: 9pt)

// Three independent columns, including the existing number element in the
// middle. Backgrounds and typography belong to each column independently.
#codly.new(
  raw("fn main() {\n    let old = 1;\n    let new = 2;\n}", lang: "rs", block: true),
  header: [Independent gutters],
  footer: [Array values and row callbacks],
  highlighted: ((3, green.lighten(80%)),),
  gutters: (
    codly.gutter-column(
      values: (none, "−", "+", none),
      width: 14pt,
      align: center,
      fill: (red.lighten(85%), blue.lighten(85%)),
      inset: 2pt,
      text: (weight: "bold", fill: purple),
    ),
    auto,
    (values: row => if row.number != none { 100 + row.number }, align: left, fill: none),
  ),
)

// Intrinsic width includes every gutter, inset, and stroke; long lines remain
// capped at the available container width, while empty lists remove gutters.
#codly.new(raw("short", block: true), width: auto, gutters: (
  (values: ("wide label",), width: 65pt, fill: yellow.lighten(70%)),
  auto,
))
#codly.new(
  raw("    a long indented source line " + "argument " * 12, block: true),
  width: auto,
  indent-guides: (width: 2),
  wrap-marker: [↪],
  gutters: ((values: ("tag",), width: 24pt, stroke: (right: blue + 0.5pt)), auto),
)
#codly.new(raw("no gutters", block: true), gutters: ())
#codly.new(raw("custom without numbering", block: true), number-enabled: false, gutters: (
  auto,
  (values: ("!",), text: (fill: red)),
))

#pagebreak()
#{
  show: codly.number-set_(placement: "outside", fill: none)
  show: codly.line-set_(fill: (luma(242), none), stroke: blue + 1pt)
  codly.new(
    raw("one\n    " + "wrapped source " * 13 + "\nthree\nfour\nfive", block: true),
    header: codly.header([Outside gutters], fill: aqua.lighten(80%)),
    footer: [Footer],
    annotations: ((start: 2, end: 4, content: [group]),),
    callouts: (
      (line: 2, body: [Plain callouts span all gutter columns]),
      (line: 3, pointer: 2, body: [Pointed bubble]),
    ),
    gutters: (
      (values: ("a", "b", "c", "d", "e"), fill: none),
      auto,
      (
        values: row => if row.kind == "skip" { "s" } else { 20 + row.source-line },
        fill: yellow.lighten(80%),
      ),
    ),
    indent-guides: (width: 2),
    wrap-marker: [↪],
    skips: ((4, 8),),
    radius: 8pt,
  )
}

// Fixed custom columns reserve their own widths before the code column.
#let marker(column, row) = [#metadata((
    column: column,
    source: row.source-line,
  ))<gutter-position>#column]
#show: codly.line-show_(it => {
  let line = e.fields(it).body
  if line.func() == raw.line {
    [#metadata(line.text)<code-position>#it]
  } else { it }
})
#codly.new(
  raw("position", block: true),
  gutters: (
    (values: row => marker(0, row), width: 24pt, inset: 0pt, align: left),
    (values: row => marker(1, row), width: 30pt, inset: 0pt, align: left),
  ),
  column-gutter: 0pt,
)
#context {
  let marks = query(<gutter-position>)
  let a = marks.first().location().position()
  let b = marks.last().location().position()
  let code = query(<code-position>).first().location().position()
  assert(calc.abs(b.x - a.x - 24pt) < 0.01pt)
  assert(code.x >= b.x + 30pt)
}
