#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 290pt, height: auto, margin: 8pt)
#let source = "abcdefghijklmnopqrstuvwxyz0123456789"
#let pink = rgb("ffc4dd")
#let paint = gradient.linear(aqua.lighten(70%), purple.lighten(70%), angle: 90deg)
#let defaults = (
  fill: paint,
  stroke: blue + 1pt,
  inset: (x: 6pt, y: 3pt),
  outset: (left: 2pt, right: 3pt, top: 1pt, bottom: 2pt),
  radius: 5pt,
  width: 90pt,
  align: left,
  gap: (x: 10pt, y: 5pt),
  pointer-align: "center",
  pointer-size: 6pt,
  pointer-height: 7pt,
  pointer-width: 14pt,
  pointer-offset: 2pt,
)

// Both the generic Elembic set rule and the convenience wrapper are supported.
#show: e.set_(codly.codly-bubble, ..defaults)
#let observe(key, body) = {
  show: codly.bubble-show_(it => [#metadata((key: key, fields: e.fields(it)))<bubble>#it])
  show: codly.callout-show_(it => [#metadata((key: key, fields: e.fields(it)))<callout>#it])
  show curve: it => [#metadata((key: key, path: it))<path>#it]
  body
}
#let sample(key, ..args) = observe(key, codly.new(raw(source, block: true), callouts: (
  (
    line: 1,
    pointer: 18,
    body: [Styled body],
    ..args.named(),
  ),
)))

#sample("inherited")
#{
  show: codly.callout-set_(bubble-fill: yellow, bubble-width: 110pt, pointer-height: 10pt)
  sample("callout-defaults")
  sample("entry", bubble-fill: none, bubble-width: 80pt, pointer-height: 4pt)
}
#sample(
  "all-local",
  bubble-fill: pink,
  bubble-stroke: none,
  bubble-inset: 5pt,
  bubble-outset: 0pt,
  bubble-radius: 0pt,
  bubble-width: 100pt,
  bubble-align: right,
  bubble-gap: 3pt,
  pointer-align: "start",
  pointer-size: 2pt,
  pointer-height: 9pt,
  pointer-width: 3pt,
  pointer-offset: -4pt,
  // These style the grid cell, not the bubble.
  fill: luma(230),
  inset: 8pt,
  align: center,
)
#{
  show: codly.bubble-set_(fill: lime.lighten(70%), align: center, pointer-width: 22pt)
  sample("nested", placement: "above")
}
#sample("restored", placement: "above", bubble-fill: auto, pointer-height: auto)
// Setting bubble styles does not turn plain rows into bubbles.
#sample("plain", pointer: none, body: [Plain row], fill: yellow.lighten(70%))

#context {
  let bubbles = query(selector(<bubble>).before(here()))
  assert.eq(bubbles.map(m => m.value.key), (
    "inherited",
    "callout-defaults",
    "entry",
    "all-local",
    "nested",
    "restored",
  ))
  let find(key) = bubbles.find(m => m.value.key == key).value.fields
  for key in ("inherited", "restored") {
    for (name, value) in defaults { assert.eq(repr(find(key).at(name)), repr(value)) }
  }
  let callout = find("callout-defaults")
  assert.eq((callout.fill, callout.width, callout.at("pointer-height")), (yellow, 110pt, 10pt))
  let local = find("entry")
  assert.eq((local.fill, local.width, local.at("pointer-height")), (none, 80pt, 4pt))
  assert.eq(local.stroke, defaults.stroke)
  for (name, value) in (
    fill: pink,
    stroke: none,
    inset: 5pt,
    outset: 0pt,
    radius: 0pt,
    width: 100pt,
    align: right,
    gap: 3pt,
    pointer-align: "start",
    pointer-size: 2pt,
    pointer-height: 9pt,
    pointer-width: 3pt,
    pointer-offset: -4pt,
  ) { assert.eq(repr(find("all-local").at(name)), repr(value)) }
  assert.eq(find("nested").align, center)
  assert.eq(find("nested").fill, lime.lighten(70%))
  assert.eq(find("nested").at("pointer-width"), 22pt)
  assert.eq(find("nested").inset, defaults.inset)
  assert.eq(query(selector(<callout>).before(here())).len(), 7)
}

#pagebreak()
// Inherited widths/gaps participate in packing and annotation layout before
// drawing. Exercise both placements, no numbering, and a spanning annotation.
#for numbers in (true, false) {
  show: codly.bubble-set_(width: 45pt, align: center, gap: (x: 6pt, y: 4pt))
  observe("group-" + repr(numbers), codly.new(
    raw(source + "\n" + source, block: true),
    number-enabled: numbers,
    annotations: ((start: 1, end: 2, content: [span]),),
    callouts: (
      (line: 1, pointer: 5, placement: "above", body: [First]),
      (line: 1, pointer: 28, placement: "above", body: [Second]),
      (line: 2, pointer: 5, body: [Third]),
      (line: 2, pointer: 28, body: [Fourth], bubble-fill: yellow),
    ),
  ))
}
#context {
  for key in ("group-true", "group-false") {
    let paths = query(<path>).filter(m => m.value.key == key)
    assert.eq(paths.len(), 4)
    for pair in paths.chunks(2) {
      assert.eq(pair.first().location().position().y, pair.last().location().position().y)
      assert(pair.last().location().position().x > pair.first().location().position().x + 50pt)
    }
  }
  // Verify resolved defaults affect real geometry/paint, not only metadata.
  for (entry, path) in query(<bubble>).zip(query(<path>)) {
    let it = entry.value.fields
    let c = path.value.path.components
    assert.eq(repr(path.value.path.fill), repr(it.fill))
    assert(
      calc.abs(c.at(1).end.last().length - c.at(2).end.last().length) == it.at("pointer-height"),
    )
    let width = it.width + if type(it.outset) == dictionary { 5pt } else { 0pt }
    assert(calc.abs(c.at(5).end.first().length - width) < 0.01pt)
    let anchor = query(<__codly-callout-anchor>).find(m => (
      m.value.owner == it.__anchor.owner
        and m.value.row == it.line
        and m.value.pointer == it.pointer
    ))
    let target = anchor.location().position().x - anchor.value.advance + it.at("pointer-offset")
    let tip = path.location().position().x + c.at(2).end.first().length
    // A negative offset with start alignment clamps to the bubble's left edge.
    assert(calc.abs(tip - calc.max(path.location().position().x, target)) < 0.01pt)
  }
}
