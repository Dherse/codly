#import "../../codly.typ" as codly
#import "../../src/lib.typ": __codly-numbering
#import "@preview/elembic:1.1.1" as e

#set page(width: 380pt, height: auto, margin: 8pt)

#assert.eq(__codly-numbering("I.", 2), numbering("I.", 2))
#assert.eq(__codly-numbering("1.1", 2, 3), numbering("1.1", 2, 3))
#assert.eq(__codly-numbering(n => [L#n], 2), [L#2])
#assert.eq(__codly-numbering(none, 2), [])

// Exercise the real display path, not just the formatter helper.
#{
  show: codly.number-set_(numbering: "I.")
  codly.new(raw("one\ntwo\nthree", block: true))
  codly.number((2, 3), none, numbering: "1.1")
  codly.number((2, 3), none, numbering: (a, b) => [#a/#b])
  codly.number([custom], none, numbering: "I.")
  codly.number(none, none, numbering: "I.")
}

// A nullable annotation formatter suppresses only the annotation number.
#{
  show: codly.annotation-show_(it => {
    let fields = e.fields(it)
    assert.eq(fields.numbering, none)
    [#metadata(fields.body)<unnumbered-annotation>#it]
  })
  codly.new(raw("source", block: true), annotations: (
    (start: 1, content: [annotation without a number], numbering: none),
  ))
}

// None suppresses the numeric suffix, separator, and suffix text, while item
// references remain independent of numbering. Test all three typed renderers.
#let check-ref(renderer, it) = {
  show text: it => {
    assert(not it.text.contains("SHOULD NOT APPEAR"))
    assert(not it.text.contains("NOR THIS"))
    if it.text in ("tag", "note") { [#metadata(it.text)<numberless-item>#it] } else { it }
  }
  renderer(codly.ref, e.fields(it))
}
#import "../../src/lib.typ": (
  __codly-line-ref-show, __codly-highlight-ref-show, __codly-annotation-ref-show,
)
#{
  show: codly.ref-set_(numbering: none)
  for local in (auto, none) {
    check-ref(__codly-line-ref-show, codly.line-ref(
      [],
      block: <code>,
      number: 1,
      numbering: local,
      separator: [SHOULD NOT APPEAR],
      suffix: [NOR THIS],
    ))
    check-ref(__codly-highlight-ref-show, codly.highlight-ref(
      [],
      block: <code>,
      line: 1,
      by: "line",
      numbering: local,
      separator: [SHOULD NOT APPEAR],
    ))
    check-ref(__codly-annotation-ref-show, codly.annotation-ref(
      [],
      block: <code>,
      line: 1,
      item: [note],
      by: "line",
      numbering: local,
      separator: [SHOULD NOT APPEAR],
      suffix: [NOR THIS],
    ))
  }
  check-ref(__codly-highlight-ref-show, codly.highlight-ref(
    [],
    block: <code>,
    line: 1,
    item: [tag],
    by: "item",
    numbering: none,
    separator: " / ",
  ))
  check-ref(__codly-annotation-ref-show, codly.annotation-ref(
    [],
    block: <code>,
    line: 1,
    item: [note],
    by: "item",
    numbering: none,
    separator: " / ",
  ))
}

#{
  show: codly.line-ref-set_(numbering: none)
  show: codly.highlight-ref-set_(numbering: none)
  show: codly.annotation-ref-set_(numbering: none)
  [@code:1 @span @note]
  [#figure(caption: [Nullable numbering])[
    #codly.new(
      raw("source", block: true),
      block-label: <code>,
      highlights: ((line: 1, label: <span>),),
      annotations: ((start: 1, label: <note>, content: [note], numbering: none),),
    )
  ]<code>]
}
#context {
  assert.eq(query(<unnumbered-annotation>).map(it => it.value), ([annotation without a number],))
  assert.eq(query(<numberless-item>).map(it => it.value), ("tag", "note"))
}
