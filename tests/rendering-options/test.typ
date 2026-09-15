#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 320pt, height: auto)

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
  ranges: ((8, 8), (3, 4), (4, 5)), smart-skip: true,
))

// Skip records are sorted once, and exact duplicates do not block later skips.
#check((1, "skip", 4, 5, "skip", 9), codly.new(
  raw("1\n2\n3\n4", block: true),
  skips: ((4, 3), (2, 2), (2, 2)),
))

// Open ranges and an omitted trailing empty line.
#check(("skip", 2, 3), codly.new(
  raw("1\n2\n3\n", block: true), range: (2,), smart-skip: true,
))

// A large displayed offset must not require a densely padded highlight array.
#{
  show grid: it => {
    assert.eq((it.fill)(1, 0), red)
    assert.eq((it.fill)(1, 1), blue)
    it
  }
  codly.new(raw("one\ntwo", block: true), offset: 1000000,
    highlighted: ((1000002, blue), (1000001, red)),
  )
}

// Default whole-line fill follows the highlight element's settings.
#{
  show: codly.highlight-set_(color: green, fill: color => color)
  show grid: it => { assert.eq((it.fill)(1, 0), green); it }
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

#context {
  for expected in query(<expected-lines>) {
    let actual = ()
    let end = query(selector(<__codly-block>).after(expected.location())).first()
    for line in query(selector(<seen-line>).after(expected.location()).before(end.location())) {
      actual.push(line.value)
    }
    assert.eq(actual, expected.value)
  }
}
