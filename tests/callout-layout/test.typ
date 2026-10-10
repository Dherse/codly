#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 180pt, height: 130pt, margin: 6pt)
#show curve: it => [#metadata(it)<path>#it]
#show: codly.callout-show_(it => [#metadata(e.fields(it))<row>#it])

// Consecutive bubbles force page breaks. Their path and body must remain on
// one page, with a valid source anchor and no duplicate or lost content.
#codly.new(
  raw(range(1, 9).map(i => "line " + str(i)).join("\n"), block: true),
  callouts: range(1, 9).map(i => (
    line: i,
    placement: if calc.odd(i) { "above" } else { "below" },
    pointer: 3,
    bubble-width: 90pt,
    body: [#metadata(i)<body-start>A wrapping explanation for line #i.#metadata(i)<body-end>],
  )),
)

#context {
  let paths = query(selector(<path>).before(here()))
  assert.eq(paths.len(), 8)
  let starts = query(<body-start>)
  let ends = query(<body-end>)
  assert.eq(starts.map(m => m.value), range(1, 9))
  assert.eq(ends.map(m => m.value), range(1, 9))
  assert(paths.map(p => p.location().position().page).dedup().len() > 1)
  for (path, start, end) in paths.zip(starts, ends) {
    assert.eq(path.location().position().page, start.location().position().page)
    assert.eq(start.location().position().page, end.location().position().page)
  }
}

// Width auto performs an intrinsic layout pass; anchors must still resolve.
#codly.new(raw("abcdef", block: true), width: auto, callouts: (
  (line: 1, pointer: 4, body: [Auto width]),
))

// Anchors use source positions through range filtering, skips, offsets and
// syntax resolution for sublanguages. Hidden rows create no bubble or anchor.
#context {
  let origin = here()
  codly.new(
    raw("hidden\nlet variable = 3;\nnext\nlast", block: true),
    range: (2, 4),
    offset: 20,
    skips: ((position: 3, length: 5),),
    sublangs: ((start: 2, end: 2, lang: "js"),),
    callouts: (
      (line: 1, pointer: 99, body: [Hidden]),
      (line: 2, pointer: 6, placement: "above", body: [Sublanguage source]),
    ),
  )
  context {
    let rows = query(selector(<row>).after(origin).before(here()))
    assert.eq(rows.len(), 1)
    assert.eq((rows.first().value.line, rows.first().value.pointer), (2, 6))
    let anchors = query(selector(<__codly-callout-anchor>).after(origin).before(here()))
    assert.eq(anchors.len(), 1)
  }
}

// Grouped bubbles remain intact when the entire group moves to a new page.
// Collisions use distinct lanes; separated anchors share a lane on either side.
#context {
  let origin = here()
  for side in ("above", "below") {
    codly.new(raw("abcdefghijklmnopqrstuvwxyz", block: true), callouts: (
      (line: 1, placement: side, pointer: 3, bubble-width: 35pt, body: [Left]),
      (line: 1, placement: side, pointer: 21, bubble-width: 35pt, body: [Right]),
      (
        line: 1,
        placement: side,
        pointer: 3,
        bubble-width: 90pt,
        body: [A collision wraps into another lane],
      ),
    ))
  }
  context {
    let paths = query(selector(<path>).after(origin).before(here()))
    assert.eq(paths.len(), 6)
    for group in paths.chunks(3) {
      assert.eq(group.map(p => p.location().position().page).dedup().len(), 1)
      assert.eq(group.at(0).location().position().y, group.at(1).location().position().y)
      assert(group.at(2).location().position().y > group.at(1).location().position().y)
    }
  }
}
