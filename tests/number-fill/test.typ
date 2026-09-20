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
  show: codly.line-set_(fill: code, zebra-fill: none)
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
  show: codly.line-set_(fill: code, zebra-fill: zebra)
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
  show: codly.line-set_(fill: code, zebra-fill: none)
  show grid: no-fill
  codly.new(raw("first\nsecond", block: true))
}

// Outside numbering uses geometry reconstruction, including across pages.
#{
  set page(height: 70pt)
  show: codly.number-set_(fill: gutter, placement: "outside")
  show: codly.line-set_(fill: code, zebra-fill: none)
  show rect: it => {
    if it.fill == gutter {
      [#metadata((width: it.width, height: it.height))<outside-number-fill>#it]
    } else {
      it
    }
  }
  codly.new(raw(range(1, 10).map(str).join("\n"), block: true), breakable: true)
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
}
