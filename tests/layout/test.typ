#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)

// Per-instance header/footer settings must reach their grid cells. Headers
// span all columns, including the annotation column.
#show grid.cell: it => {
  [#metadata((colspan: it.colspan, fill: it.fill, inset: it.inset))<grid-cell>#it]
}

#codly.new(
  raw("one\ntwo", block: true),
  annotations: ((start: 1, content: [note]),),
  header: codly.codly-header([header-numbered], fill: red, inset: 2pt),
  footer: codly.codly-footer([footer-numbered], fill: blue, inset: 3pt),
)

#codly.new(
  raw("one\ntwo", block: true),
  number-enabled: false,
  annotations: ((start: 1, content: [note]),),
  header: codly.codly-header([header-plain], fill: green, inset: 4pt),
  footer: codly.codly-footer([footer-plain], fill: purple, inset: 5pt),
)

// An explicit `none` preserves an unfilled outside number column.
#let line-gradient = gradient.linear(red, blue)
#let zebra-tiling = tiling(
  size: (4pt, 4pt),
  relative: "parent",
  rect(width: 2pt, height: 2pt),
)
#{
  show: codly.line-set_(fill: line-gradient, zebra-fill: zebra-tiling)
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  show rect: it => [#metadata(it.fill)<complex-fill>#it]
  codly.new(raw("gradient\ntiling", block: true))
}

// This is also a visual regression for repeated headers and footers across a
// page break; the metadata asserts that the per-instance repeat flag is used.
// Explicit insets keep header text within Typst's continuation clipping region.
#let repeat-case() = {
  set page(height: 180pt, margin: 6pt)
  show: e.show_(codly.codly-header, it => [#metadata(e.fields(it).repeat)<header-repeat>#it])
  show: e.show_(codly.codly-footer, it => [#metadata(e.fields(it).repeat)<footer-repeat>#it])
  codly.new(
    raw(range(1, 14).map(str).join("\n"), block: true),
    breakable: true,
    header: codly.codly-header([repeat header], repeat: true, fill: luma(230), inset: 1em),
    footer: codly.codly-footer([repeat footer], repeat: true, fill: luma(235), inset: 1em),
  )
}

#repeat-case()

#context {
  assert.eq(query(<complex-fill>).map(it => type(it.value)), (
    type(zebra-tiling),
    type(line-gradient),
  ))
  let cells = query(<grid-cell>)
    .map(it => it.value)
    .filter(it => (
      it.fill
        in (
          red,
          blue,
          green,
          purple,
        )
    ))
  assert.eq(cells, (
    (colspan: 3, fill: red, inset: 2pt),
    (colspan: 3, fill: blue, inset: 3pt),
    (colspan: 2, fill: green, inset: 4pt),
    (colspan: 2, fill: purple, inset: 5pt),
  ))
  for label in (<header-repeat>, <footer-repeat>) {
    let repeats = query(label).map(it => it.value)
    assert(repeats.len() > 1)
    for repeat in repeats { assert.eq(repeat, true) }
  }
}
