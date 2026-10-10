#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 290pt, height: auto, margin: 8pt)

#show: codly.callout-set_(bubble-fill: gradient.linear(rgb("dbf0ff"), rgb("fce2ee"), angle: 90deg))
#let source = "const [amet, consectetur] = [0, 0]"

// Keep the native path inspectable: one closed outline owns both fill and
// stroke, with no rectangle/triangle seam.
#show curve: it => [#metadata(it)<bubble-path>#it]
#show: codly.callout-show_(it => [#metadata(e.fields(it))<bubble-fields>#it])

#codly.new(raw(source, lang: "js", block: true), callouts: (
  (line: 1, pointer: 9, body: [This is a callout]),
  (line: 1, pointer: 1, body: [Clamped at the left]),
  (line: 1, pointer: source.len(), body: [Clamped at the right]),
))

// Local bubble properties override element defaults independently of the row.
// Long body text wraps natively inside the measured outline.
#codly.new(raw(source, block: true), number-enabled: false, callouts: (
  (line: 1, pointer: 16, pointer-align: "start", body: [Start], bubble-fill: yellow),
  (line: 1, pointer: 16, pointer-align: "end", body: [End], bubble-radius: 8pt),
  (
    line: 1,
    pointer: 20,
    body: [A longer *styled explanation* that must wrap across several lines inside the bubble without any manually inserted line breaks.],
    fill: luma(225),
    bubble-inset: (x: 10pt, y: 7pt),
    bubble-outset: (x: 3pt, y: 2pt),
    bubble-stroke: 1.5pt + gradient.linear(blue, red),
    pointer-size: 7pt,
  ),
))

// A wrapped source, nested highlights and a spanning annotation all share the
// actual source character anchor, even when numbering is outside the block.
#{
  show: codly.number-set_(placement: "outside")
  codly.new(
    raw(
      "root {\n    long_call(alpha, beta, gamma, delta, epsilon, zeta);\n}",
      block: true,
      lang: "js",
    ),
    width: 245pt,
    indent-guides: true,
    wrap-marker: [>],
    rainbow: true,
    annotations: ((start: 1, end: 3, content: [span]),),
    highlights: ((line: 2, start: 5, end: 14),),
    callouts: ((line: 2, pointer: 44, body: [Wrapped source anchor], bubble-width: 70%),),
  )
}

// Earlier annotations release their column; the next active annotation keeps
// the brace column separate. Callouts keep source positions despite offsets.
#codly.new(
  raw("before\nabcdefghijklmnopqrst\nafter", block: true),
  offset: 100,
  annotations: ((start: 1, content: [before]), (start: 3, content: [after])),
  callouts: ((line: 2, pointer: 18, body: [Freed annotation column], bubble-fill: none),),
)

#context {
  let paths = query(selector(<bubble-path>).before(here()))
  assert.eq(paths.len(), 8)
  assert(paths.all(p => p.value.fill != auto))
  assert.eq(query(selector(<__codly-callout-anchor>).before(here())).len(), 7)
  for path in paths {
    let fields = query(selector(<bubble-fields>).before(path.location())).last().value
    let anchor = query(<__codly-callout-anchor>).find(m => (
      m.value.owner == fields.__anchor.owner
        and m.value.row == fields.line
        and m.value.pointer == fields.pointer
    ))
    assert(anchor != none)
    let tip = path.value.components.at(2).end.first().length
    let expected = anchor.location().position().x - anchor.value.advance
    assert(calc.abs(path.location().position().x + tip - expected) < 0.01pt)
    // Painted outline stays within the page even when the bubble shifts.
    let width = path.value.components.at(5).end.first().length
    assert(path.location().position().x >= 8pt)
    assert(path.location().position().x + width <= 282pt)
  }
  assert.eq(repr(paths.first().value.fill), repr(paths.at(2).value.fill))
  assert.eq(paths.at(3).value.fill, yellow)
  assert.eq(paths.last().value.fill, none)
  // The long body really wrapped, rather than overflowing a one-line box.
  assert(paths.at(5).value.components.at(8).end.last().length > 40pt)
}

#pagebreak()
// Near both row edges, the bubble shifts while the arrow follows the source.
#codly.new(
  raw("0123456789012345678901234567890123456789012345678", block: true),
  number-enabled: false,
  callouts: (
    (line: 1, pointer: 1, body: [Left edge]),
    (line: 1, pointer: 49, body: [Right edge]),
  ),
)
// Numbering and annotation states do not change source character coordinates.
#for numbers in (true, false) {
  codly.new(
    raw("before\n    abcdefghijklmnopqrstuvwxyz\nafter", block: true),
    number-enabled: numbers,
    column-gutter: 5pt,
    row-gutter: 2pt,
    annotations: ((start: 1, content: [before]),),
    callouts: (
      (line: 2, pointer: 25, body: [Right edge and released brace column], bubble-width: 160pt),
    ),
  )
  codly.new(
    raw("before\n    abcdefghijklmnopqrstuvwxyz\nafter", block: true),
    number-enabled: numbers,
    annotations: ((start: 1, end: 3, content: [span]),),
    callouts: (
      (
        line: 2,
        pointer: 6,
        body: [Inside a brace],
        bubble-stroke: none,
        bubble-fill: tiling(size: (4pt, 4pt), rect(
          width: 2pt,
          height: 4pt,
          fill: aqua,
          stroke: none,
        )),
      ),
      (line: 2, pointer: 0, body: [Line start], bubble-radius: 0pt, pointer-size: 8pt),
    ),
  )
}

// Unicode, explicit body breaks, full-width bubbles, and a narrow container.
#codly.new(raw("let café = \"🙂\";", block: true, lang: "js"), width: 140pt, callouts: (
  (
    line: 1,
    pointer: 8,
    body: [Explicit#linebreak()body lines],
    bubble-width: 100%,
    bubble-outset: (left: 1pt, right: 5pt, top: 2pt, bottom: 3pt),
  ),
))

// Setting a pointer on the element enables bubbles; an entry can turn it off.
#{
  show: codly.callout-set_(pointer: 3, bubble-fill: yellow, bubble-inset: 8pt)
  codly.new(raw("abc\ndef", block: true), callouts: (
    (line: 1, body: [Inherited bubble]),
    (line: 2, pointer: none, body: [Plain row]),
  ))
}
