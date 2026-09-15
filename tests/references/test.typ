#import "../../codly.typ" as codly

#set page(width: 400pt, height: auto)
#set heading(numbering: "1")

// Native forward references; no initialization or custom ref show rule.
@code:1 @marked @note

#figure(caption: [Code])[
  #codly.new(raw("first\nsecond\nthird", block: true), block-label: <code>,
    highlights: ((line: 1, start: 1, end: 3, label: <marked>),),
    annotations: ((start: 2, label: <note>),),
  )
]<code>

#show: codly.ref-set_(by: "item")
#figure(caption: [Tagged code])[
  #codly.new(raw("one", block: true), block-label: <tagged>,
    highlights: ((line: 1, tag: [A], label: <tag>),),
  )
]<tagged>
@tag @tagged:1

= Ordinary heading <heading>
@heading @code @tagged

#context {
  for target in (<code:1>, <marked>, <note>, <tag>, <tagged:1>) {
    assert.eq(query(target).first().func(), figure)
  }
  assert.eq(query(figure.where(kind: "codly-line")).len(), 4)
  assert.eq(query(figure.where(kind: "__codly-end-block")).len(), 0)
  assert.eq(codly.info(<code>), (last-number: 3, lines: 3))
  assert.eq(counter(figure.where(kind: query(<tagged>).first().kind)).at(<tagged>), (2,))
}
