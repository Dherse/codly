#import "../../codly.typ" as codly
#import "../../src/padding.typ" as impl
#import "@preview/elembic:1.1.1" as e

#set page(width: 420pt, height: auto, margin: 8pt)
#set text(size: 9pt)
#context {
  assert.eq(impl.resolve(0pt), (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt))
  assert.eq(impl.resolve((rest: 2pt, x: 4pt, top: 6pt)), (
    top: 6pt,
    right: 4pt,
    bottom: 2pt,
    left: 4pt,
  ))
  assert.eq(impl.resolve(1em).top, 9pt)
}

// Intrinsic sizing includes all four edges, also with custom outside gutters.
#for outside in (false, true) {
  show: codly.number-set_(placement: if outside { "outside" } else { "inside" })
  context {
    let block(padding) = codly.new(
      raw("one\ntwo", block: true),
      width: auto,
      padding: padding,
      gutters: (auto, (values: ("tag", "tag"), width: 30pt)),
    )
    let base = measure(block(0pt))
    let padded = measure(block((left: 7pt, right: 11pt, top: 13pt, bottom: 17pt)))
    assert(calc.abs(padded.width - base.width - 18pt) < 0.01pt)
    assert(calc.abs(padded.height - base.height - 30pt) < 0.01pt)
    block((y: 8pt))
  }
}

// Adding edge space must not change interior line spacing, callbacks, or
// palette indices. Nor should it alter line references or block information.
#show: codly.line-show_(it => {
  [#metadata(e.fields(it).body.text)<padding-line>#it]
})
#for padding in (0pt, (top: 12pt, bottom: 20pt)) {
  codly.new(raw("A\nB\nC", block: true), padding: padding)
}
#context {
  let positions = query(selector(<padding-line>).before(here())).map(it => {
    it.location().position().y
  })
  assert.eq(positions.len(), 6)
  assert(calc.abs(positions.at(1) - positions.at(0) - positions.at(4) + positions.at(3)) < 0.01pt)
  assert(calc.abs(positions.at(2) - positions.at(1) - positions.at(5) + positions.at(4)) < 0.01pt)
}
#figure(caption: [Padding and references])[
  #codly.new(
    raw("one\ntwo", block: true),
    padding: 10pt,
    block-label: <padded>,
    highlighted: (1,),
    callouts: ((line: 2, body: [Note]),),
    header: [Header],
    footer: [Footer],
  )
]<padded>
#context {
  assert.eq(codly.info(<padded>), (last-number: 2, lines: 2))
  assert.eq(query(<padded:1>).len(), 1)
  assert.eq(query(<padded:2>).len(), 1)
}
