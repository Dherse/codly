#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#let first = rgb("e8f4ff")
#let second = rgb("fff1d6")
#let skipped = rgb("eeeeee")
#let callout = rgb("e9ddff")
#let unnumbered = rgb("dff6df")
#let fourth = rgb("ffe1e8")

// Record code and number-column fills after evaluating palettes and callbacks.
// With fill: auto, the number column should match the code column.
#let record-fills(tag, rows, it) = {
  if it.fill == none { return it }
  let fills = ()
  for y in range(rows) { fills.push(((it.fill)(0, y), (it.fill)(1, y))) }
  [#metadata((tag: tag, fills: fills))<row-fill>#it]
}

// `auto` resolves to the documented two-item default palette.
#{
  show: codly.line-set_(fill: auto)
  show grid: it => record-fills("auto", 2, it)
  codly.new(raw("first\nsecond", block: true))
}

// A scalar `none` is distinct from a palette entry and applies to every row.
#{
  show: codly.line-set_(fill: none)
  show grid: it => record-fills("none", 2, it)
  codly.new(raw("first\nsecond", block: true))
}

// The outside-number reconstruction reads the same `auto` gutter fill.
#{
  show: codly.number-set_(placement: "outside", fill: auto)
  show: codly.line-set_(fill: (first, second))
  [#metadata(none)<outside-auto-start>]
  codly.new(raw("first\nsecond", block: true))
  [#metadata(none)<outside-auto-end>]
}

// Check row metadata and fill order for code, skips, callouts, and unnumbered lines.
#let callback-fill(row) = {
  if row.kind == "callout" {
    assert.eq((row.index, row.at("source-line"), row.number), (1, 1, 1))
    return callout
  }
  if row.kind == "skip" {
    assert.eq((row.index, row.at("source-line"), row.number), (2, none, none))
    return skipped
  }
  assert.eq(row.kind, "code")
  if row.at("source-line") == 1 {
    assert.eq((row.index, row.number), (0, 1))
    first
  } else if row.at("source-line") == 2 {
    assert.eq((row.index, row.number), (3, 2))
    second
  } else if row.at("source-line") == 3 {
    assert.eq((row.index, row.number), (4, none))
    unnumbered
  } else {
    assert.eq((row.at("source-line"), row.index, row.number), (4, 5, 3))
    fourth
  }
}

#{
  show: codly.line-set_(fill: callback-fill)
  show grid: it => record-fills("callback", 6, it)
  codly.new(
    raw("one\ntwo\nthree\nfour", block: true),
    skips: ((2, 0),),
    callouts: ((line: 1, body: [Attached callout]),),
    unnumbered: (3,),
  )
}

#context {
  let fills = query(<row-fill>).map(it => it.value)
  assert.eq(fills.find(it => it.tag == "auto").fills, (
    (luma(240), luma(240)),
    (none, none),
  ))
  assert.eq(fills.find(it => it.tag == "none").fills, (
    (none, none),
    (none, none),
  ))
  let start = query(<outside-auto-start>).first()
  let end = query(<outside-auto-end>).first()
  let outside-numbers = query(
    selector(<__codly-geometry>).after(start.location()).before(end.location()),
  ).filter(it => it.value.kind == "cell-start" and it.value.x == 0)
  assert.eq(outside-numbers.map(it => it.value.fill), (first, second))
  assert.eq(fills.find(it => it.tag == "callback").fills, (
    (first, first),
    (callout, callout),
    (skipped, skipped),
    (second, second),
    (unnumbered, unnumbered),
    (fourth, fourth),
  ))
}
