#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 200pt, height: auto, margin: 20pt)

#let example(stroke, outside: false) = {
  show: codly.line-set_(stroke: stroke, fill: white, zebra-fill: none)
  show: e.set_(codly.codly-number, placement: if outside { "outside" } else { "inside" })
  codly.new(raw("margin check\nsecond line", block: true), radius: 0pt)
}

#context {
  let plain = measure(example(none), width: 160pt)
  for stroke in (red + 8pt, stroke(paint: blue)) {
    let thickness = if stroke.thickness == auto { 1pt } else { stroke.thickness }
    let bordered = measure(example(stroke), width: 160pt)
    assert.eq(bordered.width, plain.width)
    assert(calc.abs(bordered.height - plain.height - thickness) < 0.001pt)
  }
}

#example(none)
#example(red + 8pt)
#example(stroke(paint: blue))
#example(red + 8pt, outside: true)

// Border space also applies at each fragment of a wrapped, breakable listing.
#{
  set page(height: 130pt, margin: 10pt)
  show: codly.line-set_(stroke: red + 4pt)
  codly.new(
    raw(
      range(1, 10)
        .map(n => str(n) + " a longer line that wraps within this narrow block")
        .join("\n"),
      block: true,
    ),
    header: codly.codly-header([header], repeat: true, inset: 1em),
    footer: codly.codly-footer([footer], repeat: true, inset: 1em),
  )
}
