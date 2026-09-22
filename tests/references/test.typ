#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 315pt, height: auto, margin: 5pt)
#set heading(numbering: "1")

// Native forward references; no global ref show rule is needed.
#show: codly.line-ref-set_(separator: "-")
#show: codly.line-ref-show_(it => {
  let fields = e.fields(it)
  [#metadata((
      number: fields.number,
      separator: fields.separator,
      suffix: fields.suffix,
    ))<line-reference>#it]
})
#show: codly.highlight-ref-show_(it => {
  let fields = e.fields(it)
  [#metadata((line: fields.line, item: fields.item, by: fields.by))<highlight-reference>#it]
})
#show: codly.annotation-ref-show_(it => {
  let fields = e.fields(it)
  [#metadata((line: fields.line, item: fields.item, by: fields.by))<annotation-reference>#it]
})

@code:1 @marked @note

#figure(caption: [Code])[
  #codly.new(
    raw("first\nsecond\nthird", block: true),
    block-label: <code>,
    highlights: ((line: 1, start: 1, end: 3, label: <marked>),),
    annotations: ((start: 2, label: <note>),),
  )
]<code>

#show: codly.ref-set_(by: "item")
#figure(caption: [Tagged code])[
  #codly.new(raw("one", block: true), block-label: <tagged>, highlights: (
    (line: 1, tag: [A], label: <tag>),
  ))
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
  assert.eq(query(<line-reference>).map(it => it.value), (
    (number: 1, separator: "-", suffix: none),
    (number: 1, separator: "-", suffix: none),
  ))
  assert.eq(query(<highlight-reference>).map(it => it.value), (
    (line: 1, item: none, by: "line"),
    (line: 1, item: [A], by: "item"),
  ))
  assert.eq(query(<annotation-reference>).map(it => it.value), (
    (line: 2, item: [1], by: "line"),
  ))
}
