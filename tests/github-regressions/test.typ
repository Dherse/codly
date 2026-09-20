#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)

#let line-marker(it) = {
  let fields = e.fields(it)
  let body = fields.body
  let value = if body.func() == raw.line {
    (number: body.number, fill: fields.fill, text: body.text)
  } else {
    (number: "skip", fill: fields.fill, text: "")
  }
  [#metadata(value)<github-line>#it]
}

// #118: whole-line highlights remain effective when line numbers are hidden.
#{
  show: codly.line-set_(fill: luma(230), zebra-fill: none)
  show: codly.highlight-set_(color: blue, fill: color => color)
  show grid: it => {
    assert.eq((it.fill)(0, 0), luma(230))
    assert.eq((it.fill)(0, 1), red)
    assert.eq((it.fill)(0, 2), blue)
    it
  }
  show: codly.line-show_(line-marker)
  codly.new(
    raw("one\ntwo\nthree", block: true),
    number-enabled: false,
    highlighted: ((2, red), 3),
  )
}

// #106: a one dimensional number alignment setting must not hide a figure's
// text when numbers are disabled.
#for alignment in (left, top) [#figure[
  #{
    show: e.set_(codly.codly-number, align: alignment)
    show: codly.line-show_(it => {
      let body = e.fields(it).body
      [#metadata(body.text)<github-figure-line>#it]
    })
    codly.new(raw("Text\nText\nText\nText", block: true), number-enabled: false)
  }
]]

// #110: `rest` still inserts the gap before a final singleton range when
// `last` is disabled.
#{
  show: codly.line-show_(line-marker)
  codly.new(
    raw("first\n\nmiddle\n\nlast", block: true),
    ranges: ((1, 1), (3, 3), (5, 5)),
    smart-skip: (first: false, last: false, rest: true),
    number-enabled: false,
  )
}

// PR #115: an empty block remains constructible with no displayed line number.
#codly.new(raw("", block: true), number-enabled: false)<github-empty>

// #94: complex line fills and headers can coexist.
#{
  show: codly.line-set_(fill: gradient.linear(red, blue))
  codly.new(raw("gradient", block: true), header: [header])
}

// #135: an explicit empty language fill is valid.
#{
  show: codly.lang-set_(fill: none, languages: (py: (name: "Python", color: green, fill: none)))
  codly.new(raw("print", lang: "py", block: true))
}

#context {
  let lines = query(<github-line>).map(it => it.value)
  assert.eq(lines.at(0).text, "one")
  assert.eq(lines.at(1).text, "two")
  assert.eq(lines.at(2).text, "three")
  assert.eq(lines.at(3).number, 1)
  assert.eq(lines.at(4).number, "skip")
  assert.eq(lines.at(5).number, 3)
  assert.eq(lines.at(6).number, "skip")
  assert.eq(lines.at(7).number, 5)
  assert.eq(codly.info(<github-empty>), (last-number: none, lines: 1))
  assert.eq(query(<github-figure-line>).map(it => it.value), ("Text",) * 8)
}
