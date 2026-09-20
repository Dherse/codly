#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 255pt, height: auto, margin: 5pt)

#let check(expected, body) = {
  show: codly.line-show_(it => {
    let line = e.fields(it).body
    [#metadata(if line.func() == raw.line { line.number } else { "skip" })<seen-line>#it]
  })
  [#metadata(expected)<expected-lines>#body]
}

// Unsorted, overlapping ranges merge; one placeholder per omitted run.
#check(("skip", 3, 4, 5, "skip", 8, "skip"), codly.new(
  raw("1\n2\n3\n4\n5\n6\n7\n8\n9\n10", block: true),
  ranges: ((8, 8), (3, 4), (4, 5)),
  smart-skip: true,
))

// Skip records are sorted once, and exact duplicates do not block later skips.
#check((1, "skip", 4, 5, "skip", 9), codly.new(
  raw("1\n2\n3\n4", block: true),
  skips: ((4, 3), (2, 2), (2, 2)),
))

// Open ranges and an omitted trailing empty line.
#check(("skip", 2, 3), codly.new(
  raw("1\n2\n3\n", block: true),
  range: (2,),
  smart-skip: true,
))

// Exercise each smart-skip switch independently and keep ordinary gaps hidden.
#for (flags, expected) in (
  ((first: true), ("skip", 2, 3, 6)),
  ((rest: true, first: false, last: false), (2, 3, "skip", 6)),
  ((last: true), (2, 3, 6, "skip")),
  (false, (2, 3, 6)),
) {
  check(expected, codly.new(
    raw("1\n2\n3\n4\n5\n6\n7\n8", block: true),
    ranges: ((2, 3), (6, 6)),
    smart-skip: flags,
  ))
}

#for (source, options, expected) in (
  ("", (:), ()),
  ("", (skip-last-empty: false), (1,)),
  ("one\n\n", (:), (1, 2)),
  ("one\n\n", (skip-last-empty: false), (1, 2, 3)),
  ("one\ntwo", (range: (20,), smart-skip: true), ("skip",)),
  ("one\ntwo", (number-enabled: false, offset: 40), (41, 42)),
) {
  check(expected, codly.new(raw(source, block: true), ..options))
}

// A large displayed offset must not require a densely padded highlight array.
#{
  show grid: it => {
    assert.eq((it.fill)(1, 0), red)
    assert.eq((it.fill)(1, 1), blue)
    it
  }
  codly.new(raw("one\ntwo", block: true), offset: 1000000, highlighted: (
    (1000002, blue),
    (1000001, red),
  ))
}

// Default whole-line fill follows the highlight element's settings.
#{
  show: codly.highlight-set_(color: green, fill: color => color)
  show grid: it => {
    assert.eq((it.fill)(1, 0), green)
    it
  }
  codly.new(raw("one", block: true), highlighted: (1,))
}

// Deferred measurements must see font changes made by a custom line show rule.
#{
  show: codly.line-show_(it => text(size: 22pt, it))
  show raw.line: it => context {
    if it.text == "" { assert.eq(it.body.children.first().height, measure[1].height) }
    it
  }
  codly.new(raw("one\n\n  two", block: true))
}

// Outside borders use displayed rows, including headers and footers.
#{
  show: e.set_(codly.codly-number, placement: "outside", fill: none)
  show: codly.line-set_(stroke: red + 1pt)
  show block: it => if type(it.stroke) == stroke and it.stroke.thickness == 1pt {
    [#metadata(it.height)<outside-outline>#it]
  } else { it }
  codly.new(raw("1\n2\n3\n4\n5", block: true), range: (2, 3), header: [head], footer: [foot])
}

#context {
  let outline = query(<outside-outline>).first()
  let marks = query(<__codly-geometry>)
  let top = marks.filter(it => it.value.kind == "cell-start").first().location().position().y
  let bottom = marks.filter(it => it.value.kind == "cell-end").last().location().position().y
  assert.eq(outline.value, bottom - top)
  for expected in query(<expected-lines>) {
    let actual = ()
    let end = query(selector(<__codly-block>).after(expected.location())).first()
    for line in query(selector(<seen-line>).after(expected.location()).before(end.location())) {
      actual.push(line.value)
    }
    assert.eq(actual, expected.value)
  }
}
