#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 220pt, height: 150pt, margin: 5pt)
#let marker = [#metadata(none)<painted-wrap>#text(fill: gray)[↪]]

// References, highlights, annotations, sublanguages, ranges and offsets.
@wrapped:12 @wrapped-highlight
#figure(caption: [Wrap markers])[
  #codly.new(
    raw(
      "root\n    f(very_long_argument, another_long_argument, argument_three);\n    next();\nend",
      lang: "js",
      block: true,
    ),
    wrap-marker: marker,
    indent-guides: true,
    rainbow: true,
    offset: 10,
    block-label: <wrapped>,
    range: (2, 3),
    sublangs: ((start: 2, end: 2, lang: "rs"),),
    highlights: ((line: 12, start: 4, end: 5, label: <wrapped-highlight>),),
    annotations: ((start: 2, end: 3, content: [note]),),
  )
]<wrapped>
#context {
  assert.eq(query(<wrapped:12>).len(), 1)
  assert.eq(query(<wrapped-highlight>).len(), 1)
  assert.eq(codly.info(<wrapped>), (last-number: 13, lines: 4))
  assert(query(<painted-wrap>).len() > 0)
}

#pagebreak()
// Every fragment of a long source row needs markers after the first visual line.
#for outside in (false, true) {
  context {
    let origin = here()
    show: e.set_(codly.codly-number, placement: if outside { "outside" } else { "inside" })
    codly.new(
      raw("    call(" + "argument, " * 80 + ");", block: true),
      wrap-marker: marker,
      indent-guides: true,
      header: [header],
      footer: [footer],
    )
    context {
      let arrows = query(selector(<painted-wrap>).after(origin).before(here()))
      assert(arrows.len() > 10)
      assert(arrows.last().location().position().page > arrows.first().location().position().page)
    }
  }
  pagebreak()
}

// Multiple columns on a page and nested Codly blocks have separate owners.
#set page(width: 420pt, height: 200pt, columns: 2)
#context {
  let origin = here()
  codly.new(raw("    " + "word " * 160, block: true), wrap-marker: marker)
  context {
    let arrows = query(selector(<painted-wrap>).after(origin).before(here()))
    assert(arrows.len() > 10)
    assert(arrows.any(m => m.location().position().x > 210pt))
  }
}

#pagebreak()
#set page(width: 420pt, height: auto, columns: 1)
// Nested blocks can reuse source row numbers without sharing continuation state.
#context {
  let origin = here()
  let nested = codly.new(
    raw("    " + "nested " * 20, block: true),
    wrap-marker: [#metadata(none)<nested-wrap>↪],
    number-enabled: false,
  )
  codly.new(
    raw("    " + "outer " * 20, block: true),
    wrap-marker: [#metadata(none)<outer-wrap>↪],
    annotations: ((start: 1, content: box(width: 130pt, nested)),),
  )
  context {
    let rows = query(selector(<__codly-wrap-row>).after(origin).before(here()))
    assert.eq(rows.len(), 2)
    assert.ne(rows.first().value.owner, rows.last().value.owner)
    assert(query(selector(<nested-wrap>).after(origin).before(here())).len() > 0)
    assert(query(selector(<outer-wrap>).after(origin).before(here())).len() > 0)
  }
}
