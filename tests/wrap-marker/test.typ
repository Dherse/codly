#import "../../codly.typ" as codly
#import "../../src/wrap.typ" as wrap
#import "@preview/elembic:1.1.1" as e

#set page(width: 230pt, height: auto, margin: 5pt)
#let marker = [#metadata(none)<painted-wrap>#text(fill: gray)[↪]]
#let source = "fn main() {\n    if ready {\n        call(very_long_argument, another_long_argument, argument_three);\n    }\n}"

// Only the wrapped source row gets markers; source text and numbering survive.
#context {
  let origin = here()
  show: codly.line-show_(it => [#metadata((
      e.fields(it).body.number,
      e.fields(it).body.text,
    ))<wrap-source>#it])
  codly.new(
    raw(source, lang: "rs", block: true),
    wrap-marker: marker,
    rainbow: true,
    indent-guides: (x-offset: 0.3em),
  )
  context {
    assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 2)
    assert.eq(
      query(selector(<wrap-source>).after(origin).before(here())).map(m => m.value.last()),
      source.split("\n"),
    )
    // Short source rows take the fast path and need no per-character tags.
    let rows = query(selector(<__codly-wrap-row>).after(origin).before(here()))
    assert.eq(rows.map(m => m.value.row), (3,))
  }
}

// An arbitrary styled text marker works through scoped defaults and overrides.
#context {
  let origin = here()
  show: codly.set_(wrap-marker: [#metadata(none)<custom-wrap>#text(red)[-->]])
  codly.new(raw(source, lang: "rs", block: true), number-enabled: false)
  context { assert(query(selector(<custom-wrap>).after(origin).before(here())).len() > 0) }
}

// Off, empty, disabled smart-indent, short lines, blank lines, and inline raw.
#context {
  let origin = here()
  show: codly.set_(wrap-marker: marker)
  codly.new(raw(source, block: true), wrap-marker: none)
  codly.new(raw(source, block: true), wrap-marker: [])
  codly.new(raw(source, block: true), smart-indent: false)
  codly.new(raw("short\n\n    short", block: true))
  codly.new(raw("inline " + "long " * 30))
  context {
    assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 0)
    assert.eq(query(selector(<__codly-wrap-point>).after(origin).before(here())).len(), 0)
  }
}

// Instrumentation keeps metrics for punctuation, repeated spaces, and graphemes.
#context {
  for source in ("f(a, b);  x/y/z", "e\u{301} = 👩‍💻; 中文中文中文", "office affine ffi") {
    for width in (45pt, 90pt, 150pt) {
      let plain = text(font: "DejaVu Sans Mono", source)
      let tagged = wrap.annotate(plain, here(), 1)
      assert.eq(
        measure(plain, width: width),
        measure(tagged, width: width),
        message: source + " " + repr(width),
      )
    }
  }
}

// Native wrap opportunities include CJK and punctuation, without splitting on spaces.
#context {
  let origin = here()
  codly.new(raw("    " + "中文中文" * 25, block: true), wrap-marker: marker)
  context { assert(query(selector(<painted-wrap>).after(origin).before(here())).len() >= 3) }
}

// A single unbreakable token overflows natively; it must not invent wraps.
#context {
  let origin = here()
  codly.new(raw("x" * 100, block: true), wrap-marker: marker)
  context { assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 0) }
}

#assert.eq(e.fields(codly.new(none)).at("wrap-marker", default: none), none)
#assert(catch(() => codly.new(none, wrap-marker: 42)) != none)

// A highlight wrapping internally reserves marker space too, and markers are
// painted above the highlight fill rather than disappearing behind it.
#context {
  let origin = here()
  codly.new(
    raw(source, lang: "rs", block: true),
    wrap-marker: marker,
    highlights: ((line: 3, start: 0, end: 999),),
    indent-guides: true,
  )
  context { assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 2) }
}

// Raised or lowered highlights on a short line are not line wraps.
#context {
  let origin = here()
  for baseline in (-8pt, 0pt, 8pt) {
    codly.new(raw("short call();", block: true), wrap-marker: marker, highlights: (
      (line: 1, start: 6, end: 10, baseline: baseline),
    ))
  }
  context { assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 0) }
}

// Tagged highlights retain their existing fixed-width layout. An overflowing
// tagged span must not be mistaken for a soft wrap.
#context {
  let origin = here()
  codly.new(raw("    " + "argument " * 15, block: true), wrap-marker: marker, highlights: (
    (line: 1, start: 1, end: 999, tag: [1]),
  ))
  context { assert.eq(query(selector(<painted-wrap>).after(origin).before(here())).len(), 0) }
}
