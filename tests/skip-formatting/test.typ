#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 180pt, height: auto, margin: 5pt)

// PR #103: explicit skips consume entries; smart skips use the final value.
#let check(options, lines, numbers) = {
  show: codly.line-show_(it => {
    let body = e.fields(it).body
    if body == none or body.func() != raw.line {
      [#metadata(body)<skip-body>#it]
    } else { it }
  })
  show: e.show_(codly.codly-number, it => {
    let body = e.fields(it).body
    if type(body) != int { [#metadata(body)<skip-number>#it] } else { it }
  })
  [#metadata((lines: lines, numbers: numbers))<expected-skips>
    #codly.new(raw("one\ntwo\nthree\nfour\nfive", block: true), ..options)]
}

#check(
  (
    skips: ((4, 0), (2, 0), (2, 0), (5, 0)),
    skip-line: ([A], [B]),
    skip-number: ([I], [II]),
  ),
  ([A], [B], [B]),
  ([I], [II], [II]),
)

#check(
  (
    skips: ((2, 0), (4, 0)),
    skip-line: [gap],
    skip-number: none,
  ),
  ([gap], [gap]),
  ([], []),
)

#check(
  (
    skips: ((2, 0), (4, 0)),
    skip-line: (none, [gap]),
    skip-number: ([I], none),
  ),
  (none, [gap]),
  ([I], []),
)

#check(
  (
    ranges: ((2, 2), (4, 4)),
    smart-skip: true,
    skips: ((2, 0), (4, 0)),
    skip-line: ([A], [B]),
    skip-number: ([I], [II]),
  ),
  ([B], [A], [B], [B], [B]),
  ([II], [I], [II], [II], [II]),
)

#check(
  (
    skips: ((2, 0),),
    skip-line: (),
    skip-number: (),
  ),
  (align(center)[ ... ],),
  ([ ... ],),
)

#check(
  (
    number-enabled: false,
    skips: ((2, 0), (4, 0)),
    skip-line: ([A], [B]),
    skip-number: ([I], [II]),
  ),
  ([A], [B]),
  (),
)

#context {
  let cases = query(<expected-skips>)
  assert.eq(cases.len(), 6)
  for case in cases {
    let end = query(selector(<__codly-block>).after(case.location())).first()
    let lines = query(selector(<skip-body>).after(case.location()).before(end.location()))
    let numbers = query(selector(<skip-number>).after(case.location()).before(end.location()))
    assert.eq(lines.map(it => it.value), case.value.lines)
    assert.eq(numbers.map(it => it.value), case.value.numbers)
  }
}
