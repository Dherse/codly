#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 290pt, height: auto, margin: 8pt)
#let source = "abcdefghijklmnopqrstuvwxyz0123456789"
#show curve: it => [#metadata(it)<outline>#it]
#show: codly.callout-show_(it => [#metadata(e.fields(it))<fields>#it])
#show: codly.callout-set_(pointer-size: 4pt, bubble-fill: gradient.linear(
  aqua.lighten(70%),
  purple.lighten(70%),
  angle: 90deg,
))

#let sample(key, ..args) = codly.new(raw(source, block: true), callouts: (
  (
    line: 1,
    pointer: 18,
    bubble-width: 120pt,
    bubble-inset: 4pt,
    body: [#box[#metadata(key)<body-start>]Text#box[#metadata(key)<body-end>]],
    ..args.named(),
  ),
))

// Default center is independent of cell alignment; local alignment overrides
// element settings. Check actual text positions, not just the field values.
#sample("center", align: left)
#sample("left", bubble-align: left)
#sample("right", bubble-align: right)
#{
  show: codly.callout-set_(
    bubble-align: right,
    pointer-height: 8pt,
    pointer-width: 20pt,
    pointer-offset: 3pt,
  )
  sample("inherited", placement: "above")
  sample(
    "override",
    bubble-align: center,
    pointer-height: 14pt,
    pointer-width: 6pt,
    pointer-offset: -9pt,
  )
}

#context {
  for (start, end, path) in query(selector(<body-start>).before(here())).zip(
    query(<body-end>),
    query(<outline>),
  ) {
    let a = start.location().position().x
    let b = end.location().position().x
    let x = path.location().position().x
    if start.value in ("center", "override") {
      assert(calc.abs((a + b) / 2 - x - 60pt) < 0.01pt, message: repr((start.value, a, b, x)))
    } else if start.value == "left" {
      assert(calc.abs(a - x - 4pt) < 0.01pt)
    } else {
      assert(calc.abs(b - x - 116pt) < 0.01pt)
    }
  }
  let entries = query(<fields>)
  assert.eq(entries.at(0).value.at("bubble-align"), center)
  assert.eq(entries.at(3).value.at("pointer-height"), 8pt)
  assert.eq(entries.at(3).value.at("pointer-width"), 20pt)
  assert.eq(entries.at(3).value.at("pointer-offset"), 3pt)
}

#pagebreak()
// Independent arrow height/base, both placements, signs, zero and exaggerated
// values. Oversized bases and offsets clamp within the single rounded outline.
#sample("tall", pointer-height: 18pt, pointer-width: 6pt, pointer-offset: -12pt)
#sample("wide", placement: "above", pointer-height: 3pt, pointer-width: 32pt, pointer-offset: 12pt)
#sample("flat", pointer-height: 0pt, pointer-width: 24pt)
#sample("thin", placement: "above", pointer-height: 12pt, pointer-width: 0pt)
#sample(
  "clamped-right",
  pointer-height: 16pt,
  pointer-width: 300pt,
  pointer-offset: 500pt,
  bubble-radius: 8pt,
)
#sample(
  "clamped-left",
  placement: "above",
  pointer-height: 16pt,
  pointer-width: 300pt,
  pointer-offset: -500pt,
  bubble-radius: 8pt,
)
#sample("shorthand", pointer-size: 9pt)

#context {
  for (path, entry) in query(<outline>).zip(query(<fields>)) {
    let it = entry.value
    let c = path.value.components
    let tip = c.at(2).end
    let base-left = c.at(1).end
    let base-right = c.at(3).end
    let width = c.at(5).end.first().length
    let expected-height = if it.at("pointer-height") == auto { it.at("pointer-size") } else {
      it.at("pointer-height")
    }
    let expected-width = if it.at("pointer-width") == auto { 2 * it.at("pointer-size") } else {
      it.at("pointer-width")
    }
    assert(
      calc.abs(
        calc.abs(tip.last().length - base-left.last().length) - expected-height.to-absolute(),
      )
        < 0.01pt,
      message: repr((it.at("pointer-height"), expected-height.to-absolute(), tip, base-left)),
    )
    let height = if it.placement == "above" { tip.last().length } else { c.at(8).end.last().length }
    let radius = calc.min(
      it.at("bubble-radius").to-absolute(),
      width / 2,
      (height - expected-height.to-absolute()) / 2,
    )
    assert(
      calc.abs(
        base-right.first().length
          - base-left.first().length
          - calc.min(expected-width.to-absolute(), width - 2 * radius),
      )
        < 0.01pt,
    )
    assert(base-left.first().length >= 0pt and base-right.first().length <= width)
    let anchor = query(<__codly-callout-anchor>).find(m => m.value.owner == it.__anchor.owner)
    let x = path.location().position().x
    let expected-tip = calc.min(x + width, calc.max(
      x,
      anchor.location().position().x - anchor.value.advance + it.at("pointer-offset"),
    ))
    assert(calc.abs(x + tip.first().length - expected-tip) < 0.01pt)
    assert.eq(c.last(), curve.close())
    assert(type(path.value.fill) == gradient)
  }
}

#pagebreak()
// Vertical spacing is local to adjacent lanes, not a global maximum. Horizontal
// spacing remains independent, and omitted axes use the documented default.
#codly.new(raw(source, block: true), callouts: (
  (line: 1, pointer: 18, body: [First], bubble-gap: (x: 0pt, y: 18pt)),
  (line: 1, pointer: 18, body: [Second], bubble-gap: (x: 0pt, y: 2pt)),
  (line: 1, pointer: 18, body: [Third], bubble-gap: (x: 0pt, y: 2pt)),
  (line: 1, pointer: 18, body: [Fourth], bubble-gap: (y: 2pt)),
))
#context {
  let paths = query(<outline>).slice(-4)
  let expected = (18pt, 2pt, 2pt)
  for (a, b, gap) in paths.zip(paths.slice(1), expected) {
    let bottom = a.location().position().y + a.value.components.at(8).end.last().length
    assert(calc.abs(b.location().position().y - bottom - gap - 0.6pt) < 0.01pt)
  }
}
