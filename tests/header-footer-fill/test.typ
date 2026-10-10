#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)

#let head = green.lighten(75%)
#let foot = purple.lighten(75%)
#let body = yellow.lighten(75%)
#let gutter = red.lighten(75%)
#let palette = (blue.lighten(75%), body, none)

#let sample(mode, style) = {
  let key = mode + "-" + style
  let expected = if style == "defaults" { (luma(240), none) } else if style == "explicit" {
    (head, foot)
  } else { (none, none) }
  let enabled = mode != "hidden"
  show: codly.number-set_(
    placement: if mode == "outside" { "outside" } else { "inside" },
    fill: gutter,
  )
  show: codly.header-set_(fill: head)
  show: e.set_(codly.footer, fill: foot)
  show: codly.line-set_(fill: if style == "defaults" { gradient.linear(aqua, blue) } else if style
    == "explicit" {
    row => {
      // Bands and geometry spacer rows must never reach the line callback.
      assert.eq(row.kind, "code")
      assert.eq(row.index, row.number)
      assert.eq(row.at("source-line"), row.number)
      body
    }
  } else { palette })
  show grid: it => {
    if it.fill != none {
      let bands = ()
      for child in it.children {
        if child.func() in (grid.header, grid.footer) {
          bands.push(child.children.first().fill)
        }
      }
      assert.eq(bands, expected)
      if style == "explicit" {
        assert.eq((it.fill)(if enabled { 1 } else { 0 }, 1), body)
      } else if style == "unfilled" {
        assert.eq((it.fill)(if enabled { 1 } else { 0 }, 1), palette.at(1))
        assert.eq((it.fill)(if enabled { 1 } else { 0 }, 2), none)
      }
    }
    it
  }
  [#metadata((key: key, outside: mode == "outside", expected: expected))<fill-case>]
  [#text(size: 8pt, key)]
  codly.new(
    raw("first\nsecond", block: true),
    number-enabled: enabled,
    header: codly.header(
      [Header],
      fill: if style == "defaults" { auto } else { expected.first() },
    ),
    footer: codly.footer(
      [Footer],
      fill: if style == "defaults" { auto } else { expected.last() },
    ),
  )
  [#metadata(key)<fill-case-end>]
}

#for mode in ("inside", "outside", "hidden") {
  for style in ("defaults", "explicit", "unfilled") { sample(mode, style) }
}

// Reconstructed outside backgrounds use the same element-owned band fills.
#context {
  let ends = query(<fill-case-end>)
  for start in query(<fill-case>).filter(it => it.value.outside) {
    let end = ends.find(it => it.value == start.value.key)
    let marks = query(
      selector(<__codly-geometry>).after(start.location()).before(end.location()),
    ).filter(it => it.value.kind == "cell-start")
    for (role, expected) in ("header", "footer").zip(start.value.expected) {
      let bands = marks.filter(it => it.value.role == role)
      assert.eq(bands.len(), 1)
      assert.eq(bands.first().value.fill, expected)
    }
  }
}
