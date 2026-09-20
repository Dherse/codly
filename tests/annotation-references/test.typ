#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#let suffix(body) = {
  if type(body) == str { body }
  else if body.has("text") { body.text }
  else if body.has("children") { body.children.map(suffix).join() }
  else { "" }
}


#set page(width: 315pt, height: auto, margin: 5pt)
#show: codly.ref-set_(sep: " / ", numbering: n => [L#n])
#show: codly.annotation-show_(it => {
  let fields = e.fields(it)
  [#metadata((fields.num, fields.body, suffix((fields.numbering)(fields.num))))<annotation-seen>#it]
})
#show grid.cell: it => {
  if it.rowspan > 1 { [#metadata(it.rowspan)<annotation-rowspan>#it] } else { it }
}

@first-note @second-note
#figure(caption: [Annotations])[
  #codly.new(raw("1\n2\n3\n4\n5\n6", block: true), offset: 10, block-label: <code>,
    annotations: (
      (start: 5, end: 6, label: <second-note>, content: [second], numbering: n => [#n!]),
      (start: 2, end: 3, label: <first-note>, content: [first]),
    ),
  )
]<code>


#context {
  assert.eq(query(<annotation-seen>).map(it => it.value), ((1, [first], "(1)"), (2, [second], "2!")))
  assert.eq(query(<annotation-rowspan>).map(it => it.value), (2, 2))
  for (target, expected) in ((<first-note>, " / L12"), (<second-note>, " / L15")) {
    let target = query(target).first()
    assert.eq(suffix((target.numbering)()), expected)
  }
}
