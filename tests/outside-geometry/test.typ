#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#show: e.set_(codly.codly-number, fill: none)

// Observe the geometry layer itself. The outer codly block has no stroke in
// outside-number mode, so these are the clipped blocks drawn by geometry.outside.
#show block: it => {
  let fields = it.fields()
  let radius = fields.at("radius", default: none)
  let stroke = fields.at("stroke", default: none)
  if fields.at("clip", default: false) {
    [#metadata((
        radius: radius,
        stroke: stroke,
        clip: fields.at("clip", default: false),
        height: fields.at("height"),
      ))<outside-background>#it]
  } else { it }
}

#let body-fill = rgb("#d7ecff")
#let zebra-fill = rgb("#ffe2b8")
#let header-fill = rgb("#d9f5df")
#let footer-fill = rgb("#f8d8e4")

// These rectangles are emitted by geometry.background, after its interval
// reconstruction, rather than by the source grid (whose fill is none).
#show rect: it => {
  let fill = it.fields().at("fill", default: none)
  if fill in (body-fill, zebra-fill, header-fill, footer-fill) {
    [#metadata((fill: fill, width: it.width, height: it.height))<outside-paint>#it]
  } else { it }
}

#let edge-text = ("repeat header", "repeat footer", "once header", "once footer")
#show text: it => if it.text in edge-text {
  [#metadata(it.text)<outside-edge-text>#it]
} else { it }

#show: codly.line-show_(it => {
  let body = e.fields(it).body
  if type(body) == content and body.func() == raw.line {
    [#metadata(body.text)<outside-code-line>#it]
  } else { it }
})

#let repeated-source = (
  "R01",
  "R02 "
    + range(4)
      .map(_ => {
        "this deliberately long source line wraps in the narrow code column so its cell crosses a region boundary "
      })
      .join(),
  "R03",
  "R04",
  "R05",
  "R06",
  "R07",
  "R08",
  "R09",
  "R10",
  "R11",
  "R12",
  "R13",
  "R14",
  "R15",
  "R16",
  "R17",
  "R18",
).join("\n")

#metadata(none)<outside-repeat>
#{
  set page(width: 210pt, height: 118pt, margin: 6pt)
  set text(size: 8pt)
  show: e.set_(codly.codly-number, placement: "outside")
  show: codly.line-set_(fill: body-fill, zebra-fill: zebra-fill, stroke: blue + 3pt)
  codly.new(
    raw(repeated-source, block: true),
    breakable: true,
    radius: 20pt,
    annotations: ((start: 2, end: 17, content: [spanning annotation]),),
    header: codly.codly-header([repeat header], repeat: true, fill: header-fill, inset: 3pt),
    footer: codly.codly-footer([repeat footer], repeat: true, fill: footer-fill, inset: 3pt),
  )
}

// Non-repeating edges must occupy only the first/final fragment while the
// geometry backdrop still has an anchor on every fragment.
#metadata(none)<outside-once>
#pagebreak()
#{
  set page(width: 210pt, height: 105pt, margin: 6pt)
  set text(size: 8pt)
  show: e.set_(codly.codly-number, placement: "outside")
  show: codly.line-set_(fill: body-fill, zebra-fill: zebra-fill, stroke: blue + 3pt)
  codly.new(
    raw(range(1, 15).map(n => "O" + str(n)).join("\n"), block: true),
    breakable: true,
    radius: 20pt,
    header: codly.codly-header([once header], repeat: false, fill: header-fill, inset: 3pt),
    footer: codly.codly-footer([once footer], repeat: false, fill: footer-fill, inset: 3pt),
  )
}

// Regions are also columns, not just pages. A distinct radius makes these
// emitted backgrounds identifiable without relying on source grid metadata.
#metadata(none)<outside-columns>
#pagebreak()
#{
  set page(width: 210pt, height: 118pt, margin: 6pt, columns: 2)
  set text(size: 7pt)
  show: e.set_(codly.codly-number, placement: "outside")
  show: codly.line-set_(fill: body-fill, zebra-fill: zebra-fill, stroke: purple + 3pt)
  codly.new(
    raw(range(1, 30).map(n => "C" + str(n)).join("\n"), block: true),
    breakable: true,
    radius: 19pt,
  )
}

// Marker scopes must keep an outside-number block in header content from
// truncating the outer block's interval collection.
#metadata(none)<outside-nested>
#pagebreak()
#{
  set page(width: 210pt, height: 118pt, margin: 6pt)
  set text(size: 8pt)
  show: e.set_(codly.codly-number, placement: "outside")
  show: codly.line-set_(fill: body-fill, zebra-fill: zebra-fill, stroke: orange + 3pt)
  codly.new(
    raw("outer one\nouter two", block: true),
    breakable: true,
    radius: 18pt,
    header: codly.codly-header(
      [outer header #{
          show: codly.line-set_(stroke: red + 2pt)
          codly.new(raw("nested", block: true), radius: 5pt)
        }],
      inset: 3pt,
    ),
  )
}

#context {
  let repeat = query(<outside-repeat>).first()
  let once = query(<outside-once>).first()
  let columns = query(<outside-columns>).first()
  let paints = query(<outside-paint>)
  let backgrounds = query(<outside-background>)

  // Rendered line elements retain every source line, including the long
  // wrapped row. The source itself is deliberately compact and deterministic.
  let lines = query(<outside-code-line>)
  assert.eq(lines.len(), 18 + 14 + 29 + 2 + 1)
  assert(lines.map(it => it.value).any(it => it.starts-with("R02")))

  // Every actual clipped backdrop preserves the requested radius and stroke.
  let wide = backgrounds.filter(it => it.value.stroke.paint == blue)
  let column-blocks = backgrounds.filter(it => it.value.stroke.paint == purple)
  let nested-outer = backgrounds.filter(it => (
    it.value.stroke.paint == orange and it.value.radius == 0% + 18pt
  ))
  let nested-inner = backgrounds.filter(it => (
    it.value.stroke.paint == red and it.value.radius == 0% + 5pt
  ))
  assert(wide.len() > 3)
  for background in wide {
    assert(background.value.clip)
    assert.eq(background.value.stroke.thickness, 3pt)
    assert.eq(background.value.radius, 0% + 20pt)
  }
  for background in column-blocks {
    assert(background.value.clip)
    assert.eq(background.value.stroke.thickness, 3pt)
    assert.eq(background.value.radius, 0% + 19pt)
  }
  assert.eq(nested-outer.len(), 1)
  assert.eq(nested-inner.len(), 1)

  // Paints exist on continuation regions. The long wrapped row and spanning
  // annotation are covered by the visual fixture; this also catches a missing
  // reconstructed paint layer (the source grid itself emits no filled rects).
  let repeat-paints = query(
    selector(<outside-paint>).after(repeat.location()).before(once.location()),
  )
  let repeat-lines = query(
    selector(<outside-code-line>).after(repeat.location()).before(once.location()),
  )
  let repeat-pages = ()
  for paint in repeat-paints {
    let page = paint.location().position().page
    if page not in repeat-pages { repeat-pages.push(page) }
  }
  assert(repeat-pages.len() > 1)
  assert(repeat-paints.len() > 8)
  assert(repeat-paints.any(it => it.value.fill == header-fill))
  assert(repeat-paints.any(it => it.value.fill == footer-fill))

  // The actual wrapped R02 row must resume before R03 on the next page.
  let wrapped = repeat-lines.filter(it => it.value.starts-with("R02")).first()
  let after-wrapped = repeat-lines.filter(it => it.value == "R03").first()
  assert(wrapped.location().position().page < after-wrapped.location().position().page)
  let wrapped-paint = repeat-paints.filter(it => {
    let p = it.location().position()
    (
      p.page == after-wrapped.location().position().page
        and calc.abs(p.x - after-wrapped.location().position().x) < 4pt
        and p.y < after-wrapped.location().position().y
        and it.value.fill == zebra-fill
    )
  })
  assert(wrapped-paint.len() > 0)

  // The annotation ends immediately before R18. Require an emitted
  // right-column rect on R18's page; source line metadata alone cannot
  // satisfy this.
  let after-annotation = repeat-lines.filter(it => it.value == "R18").first()
  let annotation-paint = repeat-paints.filter(it => {
    let p = it.location().position()
    (
      p.page == after-annotation.location().position().page
        and p.x > after-annotation.location().position().x
        and it.value.fill == zebra-fill
    )
  })
  assert(annotation-paint.len() > 0)

  // Show-rule metadata is cloned with the repeated visible content; false
  // repetition leaves one actual header/footer text instance each.
  let visible = query(<outside-edge-text>).map(it => it.value)
  assert(visible.filter(it => it == "repeat header").len() > 1)
  assert(visible.filter(it => it == "repeat footer").len() > 1)
  assert.eq(visible.filter(it => it == "once header").len(), 1)
  assert.eq(visible.filter(it => it == "once footer").len(), 1)

  // At least two geometry blocks are laid out at different horizontal
  // positions in the multi-column case.
  let column-xs = ()
  for background in column-blocks {
    let x = background.location().position().x
    if x not in column-xs { column-xs.push(x) }
  }
  assert(column-xs.len() > 1)
}
