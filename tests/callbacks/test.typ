#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 285pt, height: auto, margin: 5pt)

// Hooks project the resolved element fields into metadata so the scoped
// values can be checked after layout, while the callbacks below assert their
// scalar inputs at the point they are evaluated.
#let line-fields(it) = {
  let fields = e.fields(it)
  [#metadata(fields.fill)<callback-line-fill>#it]
}

#let highlight-fields(it) = {
  let fields = e.fields(it)
  [#metadata(fields.color)<callback-highlight-color>#it]
}

#let lang-fields(it) = {
  let fields = e.fields(it)
  let definition = fields.languages.at("py")
  [#metadata(definition.color)<callback-lang-color>#it]
}

#let number-fields(it) = {
  [#metadata(e.fields(it).body)<callback-number>#it]
}

#let highlight-fill(color) = {
  assert.eq(color, red)
  color.lighten(70%)
}
#let highlight-stroke(color) = {
  assert.eq(color, red)
  0.5pt + color
}
#let language-fill(lang) = {
  assert.eq(lang, (name: [Python], icon: "P", color: red))
  red.lighten(70%)
}
#let language-stroke(lang) = {
  assert.eq(lang, (name: [Python], icon: "P", color: red))
  0.5pt + red
}

// A nested scope overrides line, highlight, and language settings, then the
// enclosing values are restored for the following block.
#{
  show: codly.line-set_(fill: red)
  show: codly.highlight-set_(color: red, fill: highlight-fill, stroke: highlight-stroke)
  show: codly.lang-set_(languages: (
    py: (
      name: [Python],
      icon: "P",
      color: red,
      fill: language-fill,
      stroke: language-stroke,
    ),
  ))
  show: codly.line-show_(line-fields)
  show: codly.highlight-show_(highlight-fields)
  show: codly.lang-show_(lang-fields)
  codly.new(raw("outer", lang: "py", block: true), highlights: ((line: 1, start: 1, end: 1),))

  {
    show: codly.line-set_(fill: blue)
    show: codly.highlight-set_(
      color: blue,
      fill: color => {
        assert.eq(color, blue)
        color.lighten(70%)
      },
      stroke: color => {
        assert.eq(color, blue)
        0.5pt + color
      },
    )
    show: codly.lang-set_(languages: (
      py: (
        name: [Python],
        icon: "P",
        color: blue,
        fill: lang => {
          assert.eq(lang, (name: [Python], icon: "P", color: blue))
          blue.lighten(70%)
        },
        stroke: lang => {
          assert.eq(lang, (name: [Python], icon: "P", color: blue))
          0.5pt + blue
        },
      ),
    ))
    codly.new(raw("inner", lang: "py", block: true), highlights: ((line: 1, start: 1, end: 1),))
  }

  codly.new(raw("outer", lang: "py", block: true), highlights: ((line: 1, start: 1, end: 1),))
}

// Offset-from uses the preceding block's displayed number. The second block
// keeps a character highlight on displayed line 9 while callbacks receive a
// scalar color from the configured highlight element.
#show: codly.highlight-set_(
  color: green,
  fill: color => {
    assert.eq(color, green)
    green.lighten(70%)
  },
  stroke: color => {
    assert.eq(color, green)
    0.5pt + green
  },
)
#show: codly.highlight-show_(highlight-fields)
#show: e.show_(codly.codly-number, number-fields)
#codly.new(raw("one\ntwo", block: true), offset: 5)<offset-source>
#codly.new(
  raw("three", block: true),
  offset: 1,
  offset-from: <offset-source>,
  highlights: ((line: 9, start: 1, end: 1),),
)

#context {
  assert.eq(query(<callback-line-fill>).map(it => it.value), (red, blue, red))
  assert.eq(query(<callback-highlight-color>).map(it => it.value), (red, blue, red, green))
  assert.eq(query(<callback-lang-color>).map(it => it.value), (red, blue, red))
  assert.eq(query(<callback-number>).map(it => it.value), (6, 7, 9))
}
