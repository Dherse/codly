#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)

// The public block field is optional, type-checked, and does not change the
// existing layout unless requested.
#assert.eq(e.fields(codly.new(none)).at("leading", default: none), none)
#assert.eq(e.fields(codly.new(none, leading: 0.2em)).leading, 0.2em)
#let grid-options = e.fields(codly.new(none, gutter: 1pt, column-gutter: 2pt, row-gutter: 3pt))
#assert.eq(grid-options.gutter, 1pt)
#assert.eq(grid-options.column-gutter, 2pt)
#assert.eq(grid-options.row-gutter, 3pt)

#let source = raw("first\nsecond", block: true, lang: "rs")

// Leading affects only vertical row padding; the horizontal inset remains
// governed by the line element's normal settings.
#context {
  let tight = measure(width: 160pt, codly.new(source, leading: 0pt))
  let default = measure(width: 160pt, codly.new(source))
  let loose = measure(width: 160pt, codly.new(source, leading: 0.6em))
  assert.eq(tight.width, default.width)
  assert.eq(default.width, loose.width)
  assert(tight.height < default.height)
  assert(default.height < loose.height)
}

// The derived vertical badge offset keeps badges clear of the top border when
// the code rows are tightened and becomes zero once there is enough padding.
#let sample(leading) = {
  show place: it => [#metadata(it.dy)<leading-badge-offset>#it]
  codly.new(source, leading: leading)
}

#sample(0.2em)
#sample(0.6em)

#context {
  let offsets = query(<leading-badge-offset>).map(it => it.value)
  assert(calc.abs(measure(h(offsets.first())).width - measure(h(0.15em)).width) < 0.001pt)
  assert(calc.abs(measure(h(offsets.last())).width) < 0.001pt)
}

// Primary-grid spacing is forwarded on every layout path. The native grid
// receives all three values so Typst can apply its normal directional override
// rules (`column-gutter`/`row-gutter` take precedence over `gutter`).
#let spacing-sample(number-enabled: true, ..options) = {
  show grid: it => {
    if it.columns.len() == if number-enabled { 2 } else { 1 } {
      [#metadata((
          column: it.at("column-gutter"),
          row: it.at("row-gutter"),
        ))<primary-grid-spacing>#it]
    } else {
      it
    }
  }
  codly.new(source, number-enabled: number-enabled, ..options)
}

#spacing-sample(gutter: 1pt)
#spacing-sample(number-enabled: false, gutter: 1pt, column-gutter: 2pt, row-gutter: 3pt)
#{
  show: codly.number-set_(placement: "outside")
  spacing-sample(gutter: 1pt, column-gutter: 2pt, row-gutter: 3pt)
}

#context assert.eq(query(<primary-grid-spacing>).map(it => it.value), (
  (column: (0% + 1pt,), row: (0% + 1pt,)),
  (column: (0% + 2pt,), row: (0% + 3pt,)),
  (column: (0% + 2pt,), row: (0% + 3pt,)),
))

// Keep an intentionally exaggerated visual fixture in the reference image.
// The first listing makes generic gutter and leading obvious; the second shows
// both directional overrides at once.
= Exaggerated grid spacing
#codly.new(
  raw("alpha\nbeta\ngamma", block: true, lang: "rs"),
  leading: 0.9em,
  gutter: 0.6em,
)

#codly.new(
  raw("one\ntwo\nthree", block: true, lang: "rs"),
  leading: 0.9em,
  gutter: 0.6em,
  column-gutter: 1.2em,
  row-gutter: 1.1em,
)
