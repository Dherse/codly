#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 200pt, height: 150pt, margin: 5pt)
#let source = (
  "root {\n    child {\n        long_call(argument_one, argument_two, argument_three);\n\n        leaf();\n    }\n}\n"
    * 3
)

// Enabling guides preserves horizontal placement, wrapping, references, and page breaks.
#for (numbers, outside, smart) in (
  (true, false, true),
  (true, true, true),
  (false, false, true),
  (true, false, false),
) {
  context {
    let origin = here()
    for enabled in (false, true) {
      pagebreak(weak: true)
      show: e.set_(codly.codly-number, placement: if outside { "outside" } else { "inside" })
      show: codly.line-set_(stroke: 0.6pt + black)
      show: codly.line-show_(it => [#metadata((enabled, e.fields(it).body.number))<guide-row>#it])
      codly.new(
        raw(source, lang: "js", block: true),
        indent-guides: enabled,
        rainbow: true,
        smart-indent: smart,
        number-enabled: numbers,
        header: [head],
        footer: [foot],
        radius: 4pt,
        annotations: ((start: 2, end: 5, content: [note]),),
        highlights: ((line: 3, start: 8, end: 17),),
        sublangs: ((start: 3, end: 3, lang: "rs"),),
      )
    }
    context {
      let runs = ((), ())
      for row in query(selector(<guide-row>).after(origin).before(here())) {
        runs
          .at(if row.value.first() { 1 } else { 0 })
          .push((row.value.last(), row.location().position()))
      }
      assert.eq(runs.first().len(), 21)
      assert.eq(runs.last().len(), 21)
      let offset = runs.last().first().last().page - runs.first().first().last().page
      for (before, after) in runs.first().zip(runs.last()) {
        assert.eq(before.first(), after.first())
        let a = before.last()
        let b = after.last()
        assert.eq((a.x, a.page + offset), (b.x, b.page))
        // The geometry renderer redistributes padding in the last row of a
        // spanning annotation at a page boundary. Keep this exception narrow.
        if not outside and before.first() == 5 {
          assert(b.y >= a.y and b.y - a.y <= 3pt)
        } else { assert.eq(a.y, b.y) }
      }
    }
  }
}

#pagebreak()
// Splitting/styling whitespace must not change smart indentation.
#context {
  let original = raw.line(
    1,
    1,
    "    wrapped source source source source source source",
    text("    wrapped source source source source source source"),
  )
  let split = raw.line(
    1,
    1,
    original.text,
    text(fill: red, "  ")
      + strong("  ")
      + text("wrapped source source source source source source"),
  )
  assert.eq(measure(codly.codly-line(original), width: 90pt), measure(
    codly.codly-line(split),
    width: 90pt,
  ))
}

// Native labels, source text, and highlight character coordinates survive.
@guide-code:12 @guide-highlight
#figure(caption: [Guides])[
  #codly.new(
    raw("root\n    call();", lang: "js", block: true),
    block-label: <guide-code>,
    offset: 10,
    indent-guides: (rainbow: true, palette: (purple, orange)),
    highlights: ((line: 12, start: 4, end: 8, label: <guide-highlight>),),
  )
]<guide-code>
#context {
  assert.eq(query(<guide-code:12>).len(), 1)
  assert.eq(query(<guide-highlight>).len(), 1)
  assert.eq(codly.info(<guide-code>), (last-number: 12, lines: 2))
}

#pagebreak()
// One logical row can span several pages: every fragment needs its guide.
#context {
  let origin = here()
  show line: it => [#metadata(it.end.last())<long-guide>#it]
  codly.new(raw("  " + "long_argument " * 120, block: true), number-enabled: false, indent-guides: (
    width: 2,
    x-offset: 0.5em,
  ))
  context {
    let strokes = query(selector(<long-guide>).after(origin).before(here()))
    assert(strokes.len() >= 3)
    assert(strokes.all(m => m.value > 0pt and m.value <= 140pt))
    let x = strokes.first().location().position().x
    assert(strokes.all(m => calc.abs(m.location().position().x - x) < 0.001pt))
  }
}
