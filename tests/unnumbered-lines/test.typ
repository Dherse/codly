#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto, margin: 5pt)

// The labels use the prior displayed line and a one-indexed position after it.
@code:l1p1 and @code:l2p1

#figure(caption: [Unnumbered label-only lines])[
  #codly.new(
    raw("first\nstart:\nsecond\ndone:\nthird", block: true),
    block-label: <code>,
    unnumbered: ((2, [😀]), 4),
  )
]<code>

#context {
  assert.eq(query(<code:1>).len(), 1)
  assert.eq(query(<code:l1p1>).len(), 1)
  assert.eq(query(<code:2>).len(), 1)
  assert.eq(query(<code:l2p1>).len(), 1)
  assert.eq(query(<code:3>).len(), 1)
  assert.eq(codly.info(<code>), (last-number: 3, lines: 5))
}
