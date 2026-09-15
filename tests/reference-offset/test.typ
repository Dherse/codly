#import "../../codly.typ" as codly

#set page(width: 400pt, height: auto)

#codly.new(
  raw("a\nb\nc", block: true),
  offset: 10,
  skips: ((2, 3),),
  number-enabled: false,
)<first>
#codly.new(raw("next", block: true), offset-from: <first>)

#codly.new(raw("", block: true), skip-last-empty: true)<empty>
#codly.new(raw("after empty", block: true), offset-from: <empty>)

#figure[
  #codly.new(raw("a\nb", block: true), offset: 20, block-label: <labeled>)
]<labeled>
#codly.new(raw("after labeled", block: true), offset-from: <labeled>)

#context {
  assert.eq(codly.info(<first>), (last-number: 16, lines: 3))
  assert.eq(codly.info(<labeled>), (last-number: 22, lines: 2))
  let ends = query(<__codly-block>)
  assert.eq(ends.map(it => it.value.last-number), (16, 17, none, 1, 22, 23))
  assert.eq(query(figure.where(kind: "__codly-raw-line")).len(), 0)
}
