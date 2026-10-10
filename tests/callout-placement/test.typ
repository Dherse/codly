#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 320pt, height: auto, margin: 8pt)
#let source = "abcdefghijklmnopqrstuvwxyz0123456789"
#let gradient-fill = gradient.linear(aqua.lighten(70%), purple.lighten(75%), angle: 90deg)

#let sample(
  key,
  entries,
  numbers: true,
  annotations: none,
  code: source + "\n" + source + "\nlast",
  ..args,
) = {
  show curve: it => [#metadata((key: key, path: it))<placed-path>#it]
  show grid.cell: it => {
    if it.rowspan > 1 { [#metadata((key: key, span: it.rowspan))<brace-span>#it] } else { it }
  }
  show: codly.line-show_(it => {
    let body = e.fields(it).body
    if body.func() == raw.line {
      [#metadata((key: key, number: body.number))<source-row>#it]
    } else { it }
  })
  show: codly.callout-show_(it => [#metadata((key: key, fields: e.fields(it)))<placed-callout>#it])
  show: codly.callout-set_(bubble-fill: gradient-fill, bubble-gap: 4pt)
  codly.new(
    raw(code, block: true),
    number-enabled: numbers,
    annotations: annotations,
    callouts: entries,
    ..args,
  )
}

// Two independent bubbles on one shared row, above and below respectively.
#sample("below", (
  (line: 1, pointer: 5, body: [Left], bubble-width: 42pt),
  (line: 1, pointer: 30, body: [Right], bubble-width: 42pt),
))
#sample("above", (
  (line: 1, pointer: 5, placement: "above", body: [Left], bubble-width: 42pt),
  (line: 1, pointer: 30, placement: "above", body: [Right], bubble-width: 42pt),
))
#sample("mixed", (
  (line: 2, pointer: 7, placement: "above", body: [Above]),
  (line: 2, pointer: 24, body: [Below]),
  (line: 2, placement: "above", body: [Plain row above], fill: yellow.lighten(70%)),
))

#context {
  for key in ("below", "above") {
    let paths = query(<placed-path>).filter(m => m.value.key == key)
    assert.eq(paths.len(), 2)
    let a = paths.first().location().position()
    let b = paths.last().location().position()
    assert.eq(a.y, b.y)
    assert(b.x > a.x + 42pt)
    let code = query(<source-row>).find(m => m.value.key == key).location().position()
    if key == "above" { assert(a.y < code.y) } else { assert(a.y > code.y) }
  }
}

#pagebreak()
// Colliding bubbles stack, with the same character anchor and no overlap.
#sample("collision", (
  (line: 1, pointer: 15, body: [First], bubble-width: 105pt),
  (line: 1, pointer: 15, body: [Second explanation wraps naturally], bubble-width: 105pt),
  (line: 1, pointer: 15, body: [Third], bubble-width: 105pt),
))
// Different heights align their arrow tips toward the source line.
#sample("above-heights", (
  (line: 1, placement: "above", pointer: 5, body: [Short], bubble-width: 40pt),
  (line: 1, placement: "above", pointer: 30, body: [A longer body that wraps], bubble-width: 60pt),
))
// Global placement inherits; local placement overrides it.
#{
  show: codly.callout-set_(placement: "above")
  sample("inherit", (
    (line: 1, pointer: 8, body: [Inherited above]),
    (line: 1, pointer: 27, placement: "below", body: [Local below]),
  ))
}

#context {
  let paths = query(<placed-path>).filter(m => m.value.key == "collision")
  for (a, b) in paths.zip(paths.slice(1)) {
    let height = a.value.path.components.at(8).end.last().length
    assert(b.location().position().y > a.location().position().y + height)
  }
  let heights = query(<placed-path>).filter(m => m.value.key == "above-heights")
  let tips = heights.map(m => (
    m.location().position().y + m.value.path.components.at(2).end.last().length
  ))
  assert(calc.abs(tips.first() - tips.last()) < 0.01pt)
  let inherited = query(<placed-callout>).filter(m => m.value.key == "inherit")
  assert.eq(inherited.map(m => m.value.fields.placement), ("above", "below"))
}

#pagebreak()
// Active braces start with the first above-row and span both grouped sides.
// A completed brace frees the last column before an above-callout.
#for numbers in (true, false) {
  sample(
    "brace-" + repr(numbers),
    (
      (line: 1, placement: "above", pointer: 5, body: [A], bubble-width: 25pt),
      (line: 1, placement: "above", pointer: 25, body: [B], bubble-width: 25pt),
      (line: 2, pointer: 5, body: [C], bubble-width: 25pt),
      (line: 2, pointer: 25, body: [D], bubble-width: 25pt),
    ),
    numbers: numbers,
    annotations: ((start: 1, end: 2, content: [spanning]),),
    row-gutter: 2pt,
  )
  sample(
    "completed-" + repr(numbers),
    (
      (line: 2, placement: "above", pointer: 20, body: [Previous brace ended]),
    ),
    numbers: numbers,
    annotations: ((start: 1, content: [before]),),
  )
}
#{
  show: codly.number-set_(placement: "outside")
  sample(
    "outside",
    (
      (line: 2, placement: "above", pointer: 6, body: [Above]),
      (line: 2, pointer: 26, body: [Below]),
    ),
    annotations: ((start: 1, end: 3, content: [brace]),),
    indent-guides: true,
  )
}

#context {
  for key in ("brace-true", "brace-false") {
    assert.eq(query(<brace-span>).filter(m => m.value.key == key).map(m => m.value.span), (4,))
  }
}

#pagebreak()
// Forward character probes track a wrapped source with highlights and guides.
#sample(
  "wrapped",
  (
    (line: 2, placement: "above", pointer: 8, body: [First], bubble-width: 35pt),
    (line: 2, placement: "above", pointer: 44, body: [Wrapped], bubble-width: 50pt),
    (line: 2, pointer: 44, body: [Same anchor below]),
  ),
  code: "root {\n    long_call(alpha, beta, gamma, delta, epsilon, zeta);\n}",
  width: 210pt,
  indent-guides: true,
  wrap-marker: [>],
  rainbow: true,
  sublangs: ((start: 1, end: 3, lang: "js"),),
  highlights: ((line: 2, start: 5, end: 14),),
  annotations: ((start: 1, end: 3, content: [span]),),
)

// Large gaps force stacking even for otherwise separated bubbles. A local
// gap overrides the element setting; above-collisions retain declaration order.
#sample("large-gap", (
  (
    line: 1,
    placement: "above",
    pointer: 5,
    body: [First],
    bubble-width: 40pt,
    bubble-gap: (x: 180pt, y: 4pt),
  ),
  (line: 1, placement: "above", pointer: 30, body: [Second], bubble-width: 40pt),
))
// Different cell styles must stay separate, but independent bubble paints
// and decorations can share one cell. Oversized spacing is not imposed here.
#sample("cell-styles", (
  (line: 1, pointer: 5, body: [Cell A], bubble-width: 45pt, fill: yellow.lighten(70%)),
  (line: 1, pointer: 30, body: [Cell B], bubble-width: 45pt, fill: aqua.lighten(70%)),
))
#sample("bubble-styles", (
  (
    line: 1,
    placement: "above",
    pointer: 5,
    body: [One],
    bubble-width: 50pt,
    bubble-outset: (left: 4pt, right: 9pt, top: 5pt, bottom: 2pt),
    bubble-gap: 0pt,
    bubble-inset: 6pt,
    bubble-stroke: 2pt + gradient.linear(blue, red),
    pointer-size: 9pt,
  ),
  (
    line: 1,
    placement: "above",
    pointer: 30,
    body: [Two],
    bubble-width: 50pt,
    bubble-gap: 0pt,
    bubble-radius: 8pt,
    bubble-fill: tiling(size: (4pt, 4pt), rect(width: 2pt, height: 4pt, fill: aqua, stroke: none)),
  ),
))

#context {
  let gaps = query(<placed-path>).filter(m => m.value.key == "large-gap")
  // Above paths start at y = h-arrow, but their arrow tip is at y = h.
  let first-height = gaps.first().value.path.components.at(2).end.last().length
  let separation = (
    gaps.last().location().position().y - gaps.first().location().position().y - first-height
  )
  assert(separation >= 4pt and separation < 5pt)
  let gap-fields = query(<placed-callout>).filter(m => m.value.key == "large-gap")
  assert.eq(gap-fields.map(m => m.value.fields.at("bubble-gap")), ((x: 180pt, y: 4pt), 4pt))
  let styled = query(<placed-path>).filter(m => m.value.key == "cell-styles")
  assert(styled.first().location().position().y < styled.last().location().position().y)
  let bubbles = query(<placed-path>).filter(m => m.value.key == "bubble-styles")
  let tips = bubbles.map(m => (
    m.location().position().y + m.value.path.components.at(2).end.last().length
  ))
  // Different stroke thicknesses reserve different half-stroke clearances.
  assert(calc.abs(tips.first() - tips.last()) < 1pt)
  // Every arrow points at the rendered source character, on either side.
  for path in query(<placed-path>) {
    let entry = query(selector(<placed-callout>).before(path.location())).last().value.fields
    let anchor = query(<__codly-callout-anchor>).find(m => (
      m.value.owner == entry.__anchor.owner
        and m.value.row == entry.line
        and m.value.pointer == entry.pointer
    ))
    assert(anchor != none)
    let tip = path.value.path.components.at(2).end
    let at = path.location().position()
    assert(
      calc.abs(at.x + tip.first().length - anchor.location().position().x + anchor.value.advance)
        < 0.01pt,
    )
    if entry.placement == "above" {
      assert(tip.last().length > 0pt)
      assert(at.y + tip.last().length < anchor.location().position().y)
    } else {
      assert.eq(tip.last().length, 0pt)
      assert(at.y > anchor.location().position().y)
    }
  }
}
