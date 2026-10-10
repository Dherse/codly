#import "../../codly.typ" as codly
#import "../../src/lib.typ": __codly-highlight-color, __codly-highlight-colors
#import "@preview/elembic:1.1.1" as e

#set page(width: 400pt, height: auto, margin: 8pt)
#let palette = (red, green, blue, orange, purple)
#assert.eq(__codly-highlight-color(red, index: 99), red)
#assert.eq(
  range(7).map(index => __codly-highlight-color(palette, index: index)),
  palette + (red, green),
)

// Observe the actual rendered component colors, not only a selector helper.
#show: codly.highlight-show_(it => {
  [#metadata((tag: e.fields(it).highlight.tag, color: e.fields(it).color))<palette-span>#it]
})
#{
  show: codly.highlight-set_(color: palette, fill: color => color, stroke: none)
  codly.new(raw("one\ntwo\nthree\nfour\nfive\nsix\nseven", block: true), highlights: (
    (line: 1, tag: "a"),
    (line: 2, fill: aqua, tag: "explicit"),
    (line: 3, tag: "b"),
    (line: 4, tag: "c"),
    (line: 5, tag: "d"),
    (line: 6, tag: "e"),
    (line: 7, tag: "wrap"),
  ))
  // Range/offset filtering does not recolor surviving records.
  codly.new(
    raw("hidden\nshown", block: true),
    offset: 10,
    range: (2,),
    highlights: ((line: 11, tag: "hidden"), (line: 12, tag: "range")),
  )
  codly.new(raw("reset", block: true), highlights: ((line: 1, tag: "reset"),))
}
#context {
  let spans = query(selector(<palette-span>).before(here())).map(it => it.value)
  assert.eq(spans.map(it => it.color), (red, red, green, blue, orange, purple, red, green, red))
  assert.eq(spans.map(it => it.tag), (
    "a",
    "explicit",
    "b",
    "c",
    "d",
    "e",
    "wrap",
    "range",
    "reset",
  ))
}

// Per-record fill callbacks consume palette slots and receive the selected
// paint, while explicit paints leave the palette index untouched.
#{
  show: codly.highlight-set_(color: (red, green, blue), fill: color => color, stroke: none)
  codly.new(raw("one\ntwo\nthree\nfour\nfive", block: true), highlights: (
    (
      line: 1,
      tag: "callback-red",
      fill: color => {
        assert.eq(color, red)
        color
      },
    ),
    (line: 2, tag: "explicit-paint", fill: aqua),
    (
      line: 3,
      tag: "callback-green",
      fill: color => {
        assert.eq(color, green)
        color
      },
    ),
    (line: 4, tag: "implicit-blue"),
    (
      line: 5,
      tag: "callback-wrap",
      fill: color => {
        assert.eq(color, red)
        color
      },
    ),
  ))
}
#context {
  let tags = ("callback-red", "explicit-paint", "callback-green", "implicit-blue", "callback-wrap")
  let spans = query(<palette-span>).map(it => it.value).filter(it => it.tag in tags)
  assert.eq(spans.map(it => it.color), (red, red, green, blue, red))
}

// Splitting/reopening callback spans must not consume additional colors.
#{
  show: codly.highlight-set_(color: palette, fill: color => color)
  codly.new(raw("abcdefghijk", block: true), highlights: (
    (
      line: 1,
      start: 1,
      end: 7,
      tag: "callback-outer",
      fill: color => {
        assert.eq(color, red)
        color
      },
    ),
    (
      line: 1,
      start: 4,
      end: 10,
      tag: "callback-cross",
      fill: color => {
        assert.eq(color, green)
        color
      },
    ),
  ))
}
#context {
  let spans = query(<palette-span>)
    .map(it => it.value)
    .filter(it => it.tag in ("callback-outer", "callback-cross"))
  assert(spans.len() > 2)
  for span in spans {
    assert.eq(span.color, if span.tag == "callback-outer" { red } else { green })
  }
}

// Splitting/reopening overlapping spans must retain each declaration's paint.
#{
  show: codly.highlight-set_(color: palette)
  codly.new(raw("abcdefghijk", block: true), highlights: (
    (line: 1, start: 1, end: 7, tag: "outer"),
    (line: 1, start: 4, end: 10, tag: "cross"),
    (line: 1, start: 5, end: 6, fill: yellow, tag: "nested"),
  ))
}
#context {
  for span in query(<palette-span>)
    .map(it => it.value)
    .filter(it => it.tag in ("outer", "cross", "nested")) {
    assert.eq(span.color, if span.tag == "cross" { green } else { red })
  }
}

// Whole-row and inline cycles are independent, explicit paints don't consume
// slots, and every whole-row fill reaches the real code and gutter cells.
#{
  show: codly.highlight-set_(color: palette, fill: color => color)
  show grid.cell: it => [#metadata((x: it.x, fill: it.fill))<palette-cell>#it]
  codly.new(raw("1\n2\n3\n4\n5\n6\n7\n8", block: true), highlighted: (
    1,
    (2, aqua),
    3,
    4,
    5,
    6,
    7,
    8,
  ))
  context {
    let cells = query(<palette-cell>).map(it => it.value).filter(it => it.x == 1)
    assert.eq(cells.map(it => it.fill), (red, aqua, green, blue, orange, purple, red, green))
  }
}

// Scalar settings and custom theme palettes remain scoped; all six themes
// offer five colors. Accent overrides still update the first default color.
#for (name, _) in codly.themes {
  let theme = codly.define-theme(base: name)
  assert.eq(theme.at("highlight-colors").len(), 5)
  assert.eq(theme.at("highlight-colors").dedup().len(), 5)
}
#let custom = codly.define-theme(base: "dark", highlight-colors: (aqua, yellow))
#assert.eq(custom.at("highlight-colors"), (aqua, yellow))
#assert.eq(codly.define-theme(base: "dark", accent: orange).at("highlight-colors").first(), orange)

#{
  show: codly.highlight-set_(color: orange)
  codly.new(raw("scalar", block: true), highlights: ((line: 1, tag: "scalar"),))
}
#context {
  assert.eq(query(<palette-span>).find(it => it.value.tag == "scalar").value.color, orange)
}

// Paint palettes also support gradients and tilings with a paint-preserving
// fill transformer; callbacks receive the scalar selected for each record.
#{
  let paints = (
    gradient.linear(red, blue),
    tiling(size: (4pt, 4pt), rect(width: 2pt, height: 4pt, fill: aqua, stroke: none)),
  )
  show: codly.highlight-set_(color: paints, fill: paint => paint, stroke: none)
  codly.new(raw("paint one\npaint two", block: true), highlights: (
    (line: 1, tag: "gradient"),
    (line: 2, tag: "tiling"),
  ))
  context {
    let seen = query(<palette-span>)
      .map(it => it.value)
      .filter(it => it.tag in ("gradient", "tiling"))
    assert.eq(repr(seen.map(it => it.color)), repr(paints))
  }
}
