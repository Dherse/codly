#import "../../codly.typ" as codly

#let gutter = rgb("#d9d9d9")
#let code = rgb("#eef3ff")
#let zebra = rgb("#fff0c9")

#set page(width: 230pt, height: auto, margin: 5pt)

// The ordinary grid path colors only the number column.
#let inside-fill(it) = {
  if it.fill != none and (it.fill)(0, 0) == gutter {
    [#metadata(((it.fill)(0, 0), (it.fill)(1, 0)))<inside-number-fill>#it]
  } else {
    it
  }
}
#{
  show: codly.number-set_(fill: gutter, placement: "inside")
  show: codly.line-set_(fill: code)
  show grid: inside-fill
  codly.new(raw("first\nsecond", block: true))
}

// The default `auto` follows the row fill, including zebra striping.
#let auto-fill(it) = {
  if it.fill != none and (it.fill)(0, 0) == zebra {
    [#metadata((
        (it.fill)(0, 0),
        (it.fill)(0, 1),
        (it.fill)(1, 0),
        (it.fill)(1, 1),
      ))<auto-number-fill>#it]
  } else {
    it
  }
}
#{
  show: codly.number-set_(placement: "inside")
  show: codly.line-set_(fill: (zebra, code))
  show grid: auto-fill
  codly.new(raw("first\nsecond", block: true))
}

// `none` leaves the number column unpainted.
#let no-fill(it) = {
  if it.fill != none and (it.fill)(0, 0) == none {
    [#metadata(((it.fill)(0, 0), (it.fill)(1, 0)))<no-number-fill>#it]
  } else {
    it
  }
}
#{
  show: codly.number-set_(fill: none, placement: "inside")
  show: codly.line-set_(fill: code)
  show grid: no-fill
  codly.new(raw("first\nsecond", block: true))
}

// Outside numbering uses geometry reconstruction, including across pages.
#{
  set page(height: 70pt)
  show: codly.number-set_(fill: gutter, placement: "outside")
  show: codly.line-set_(fill: code)
  show rect: it => {
    if it.fill == gutter {
      [#metadata((width: it.width, height: it.height))<outside-number-fill>#it]
    } else {
      it
    }
  }
  codly.new(raw(range(1, 10).map(str).join("\n"), block: true), breakable: true)
}

// A palette cycles by displayed row and `auto` number fills mirror it.
#let palette = (red.lighten(75%), green.lighten(75%), blue.lighten(75%))
#let palette-fill(it) = {
  if it.fill != none and (it.fill)(0, 0) == palette.first() {
    let fills = ()
    for y in range(5) { fills.push(((it.fill)(0, y), (it.fill)(1, y))) }
    [#metadata(fills)<palette-fill>#it]
  } else {
    it
  }
}
#{
  show: codly.number-set_(placement: "inside", fill: auto)
  show: codly.line-set_(fill: palette)
  show grid: palette-fill
  codly.new(
    raw("first\nsecond\nthird\nfourth\nfifth", block: true),
    highlighted: ((2, fuchsia.lighten(75%)),),
  )
}

// Callback rows expose source and displayed line data before grid layout.
#let callback-fill(row) = if row.kind == "code" and row.at("source-line") == 2 {
  yellow.lighten(70%)
} else {
  luma(245)
}
#let callback-grid(it) = {
  if it.fill != none {
    let fills = ()
    for y in range(3) { fills.push(((it.fill)(0, y), (it.fill)(1, y))) }
    [#metadata(fills)<callback-fill>#it]
  } else {
    it
  }
}
#{
  show: codly.number-set_(placement: "inside", fill: auto)
  show: codly.line-set_(fill: callback-fill)
  show grid: callback-grid
  codly.new(raw("first\nsecond\nthird", block: true))
}

#context {
  assert.eq(query(<inside-number-fill>).map(it => it.value), ((gutter, code),))
  assert.eq(query(<auto-number-fill>).map(it => it.value), ((zebra, code, zebra, code),))
  assert.eq(query(<no-number-fill>).map(it => it.value), ((none, code),))
  let outside = query(<outside-number-fill>)
  let pages = ()
  for item in outside {
    let page = item.location().position().page
    if page not in pages { pages.push(page) }
  }
  assert(outside.len() > 1)
  assert(pages.len() > 1)
  assert(outside.all(it => it.value.width > 0pt and it.value.height > 0pt))
  assert.eq(query(<palette-fill>).map(it => it.value), (
    (
      (palette.at(0), palette.at(0)),
      (fuchsia.lighten(75%), fuchsia.lighten(75%)),
      (palette.at(2), palette.at(2)),
      (palette.at(0), palette.at(0)),
      (palette.at(1), palette.at(1)),
    ),
  ))
  assert.eq(query(<callback-fill>).map(it => it.value), (
    (
      (luma(245), luma(245)),
      (yellow.lighten(70%), yellow.lighten(70%)),
      (luma(245), luma(245)),
    ),
  ))
}
