#import "../../codly.typ" as codly
#import "../../src/indent.typ" as ind
#import "@preview/elembic:1.1.1" as e

#set page(width: 260pt, height: auto, margin: 5pt)

#let scan(source, ..options) = ind.scan(source.split("\n"), ..options)
#for width in (1, 2, 3, 4, 8) {
  let source = (
    "root\n"
      + " " * width
      + "child\n"
      + " " * (width * 2)
      + "leaf\n"
      + " " * width
      + "sibling\nroot"
  )
  assert.eq(scan(source), (width: width, depths: (0, 1, 2, 1, 0)))
}
#assert.eq(scan(""), (width: 4, depths: (0,)))
#assert.eq(scan("a\nb\nc"), (width: 4, depths: (0, 0, 0)))
#assert.eq(scan("\n \n    \n"), (width: 4, depths: (0, 0, 0, 0)))
#assert.eq(
  scan("root\n    child\n        leaf\n             aligned\n        leaf\n    child\nroot"),
  (width: 4, depths: (0, 1, 2, 3, 2, 1, 0)),
)
#assert.eq(scan("    cropped\n        leaf\n    cropped"), (width: 4, depths: (1, 2, 1)))
#assert.eq(scan("a\n    b\n       alignment\n    c", width: 4).depths, (0, 1, 1, 1))
#assert.eq(scan("\n    a\n\n \n        b\n\n    c\n  \n", width: 4).depths, (
  0,
  1,
  1,
  1,
  2,
  1,
  1,
  0,
  0,
))
#assert.eq(scan("    a\n\n    b", width: 4, blank-lines: false).depths, (1, 0, 1))
#assert.eq("  é😀".match(ind.leading-spaces).text, "  ")
#assert.eq("\u{a0}text".match(ind.leading-spaces).text, "")
#assert.eq("　text".match(ind.leading-spaces).text, "")

// Match rendered whitespace across tab stops and CRLF, including a mixed prefix.
#for size in (2, 4, 8) {
  set raw(tab-size: size)
  show raw: it => {
    assert.eq(it.lines.map(l => l.text), (
      "root",
      " " * size + "child",
      " " * (2 * size) + "leaf",
      " " * (size + 1) + "mixed",
      " " * size + "child",
      "root",
    ))
    assert.eq(ind.scan(it.lines.map(l => l.text)), (width: size, depths: (0, 1, 2, 1, 1, 0)))
  }
  raw("root\r\n\tchild\r\n\t\tleaf\r\n \t mixed\r\n\tchild\r\nroot", block: true)
}

#let colors = (red, blue)
#assert.eq(e.fields(codly.new(none, indent-guides: true)).indent-guides.enabled, true)
#assert.eq(e.fields(codly.new(none, indent-guides: false)).indent-guides.enabled, false)
#assert.eq(e.fields(codly.indent-guides(palette: colors)).palette, colors)
#let style = ind.settings(e.fields(codly.indent-guides()), codly.rainbow(
  palette: colors,
  depth-offset: 1,
))
#assert.eq(style.palette, colors)
#assert.eq(style.depth-offset, 1)
#assert.eq(
  ind
    .settings(e.fields(codly.indent-guides(rainbow: false, color: green)), codly.rainbow())
    .palette,
  (green,),
)
#assert.eq(
  ind.settings(e.fields(codly.indent-guides(rainbow: true, palette: colors)), none).palette,
  colors,
)

// Hidden rows still determine width; offsets and inserted skips only affect labels.
#context {
  let origin = here()
  codly.new(
    raw("root {\n    first {\n        leaf\n    }\n}", lang: "rs", block: true),
    indent-guides: true,
    rainbow: (palette: colors, depth-offset: 1),
    range: (3, 3),
    offset: 20,
    skips: ((position: 3, length: 5),),
  )
  context {
    let marks = query(selector(<__codly-geometry>).after(origin).before(here())).filter(m => (
      m.value.kind == "cell-start" and m.value.at("guides", default: ()) != ()
    ))
    assert.eq(marks.len(), 1)
    assert.eq(marks.first().value.guides.map(g => g.color), (blue, red))
  }
}

// Explicit monochrome overrides rainbow; local false suppresses inherited guides.
#context {
  let origin = here()
  show: codly.set_(indent-guides: true)
  codly.new(raw("a\n    b", block: true), indent-guides: false)
  codly.new(raw("flat\ncode", block: true))
  context {
    assert.eq(query(selector(<__codly-geometry>).after(origin).before(here())).len(), 0)
  }
}

#context {
  let origin = here()
  codly.new(
    raw("{\n    {\n        x\n    }\n}", lang: "js", block: true),
    rainbow: true,
    indent-guides: (rainbow: false, color: green, thickness: 0.04em),
  )
  context {
    let marks = query(selector(<__codly-geometry>).after(origin).before(here())).filter(m => (
      m.value.kind == "cell-start"
    ))
    for m in marks { assert(m.value.guides.all(g => g.color == green)) }
  }
}

// Diagnostics go through constructors and public block casts.
#for (options, message) in (
  ((width: 0), "width must be positive"),
  ((width: -2), "width must be positive"),
  ((palette: ()), "palette must not be empty"),
  ((depth-offset: -1), "depth-offset must be nonnegative"),
  ((thickness: 0pt), "thickness must be positive"),
  ((thickness: -1pt), "thickness must be positive"),
) {
  let error = catch(() => measure(codly.new(raw("a\n  b", block: true), indent-guides: options)))
  assert(error != none and error.contains(message))
}
#for options in ((width: 2.5), (rainbow: "yes"), (palette: ("red",)), (blank-lines: 1)) {
  assert(catch(() => measure(codly.new(raw("a", block: true), indent-guides: options))) != none)
}

// Verify actual strokes, palette cycling, and full-height wrapped guides.
#context {
  let origin = here()
  show line: it => [#metadata((end: it.end, stroke: it.stroke))<guide-segment>#it]
  codly.new(
    raw(
      "root\n  a\n    b\n      c\n        long_call(argument_one, argument_two, argument_three, argument_four)",
      block: true,
    ),
    indent-guides: (width: 2, rainbow: true, palette: colors, depth-offset: 1),
  )
  context {
    let strokes = query(selector(<guide-segment>).after(origin).before(here())).map(m => m.value)
    assert.eq(strokes.len(), 10)
    assert.eq(strokes.map(s => s.stroke.paint), (
      blue,
      blue,
      red,
      blue,
      red,
      blue,
      blue,
      red,
      blue,
      red,
    ))
    assert(strokes.all(s => s.end.last() > 0pt))
    assert(strokes.last().end.last() > strokes.first().end.last())
  }
}

// Disabling smart indentation limits strokes to the first visual row.
#context {
  let origin = here()
  for smart in (false, true) {
    show line: it => [#metadata((smart, it.end.last()))<guide-wrap>#it]
    codly.new(
      raw("  call(" + "long_argument, " * 14 + ")", block: true),
      indent-guides: (width: 2),
      smart-indent: smart,
    )
  }
  context {
    let lengths = query(selector(<guide-wrap>).after(origin).before(here())).map(
      m => m.value.last(),
    )
    assert.eq(lengths.len(), 2)
    assert(lengths.last() > lengths.first())
  }
}
