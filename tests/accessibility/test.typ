#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)
#set document(title: "Codly accessibility")
#set text(lang: "en")

// Plain code remains a normal accessible text block.
#codly.new(raw("plain source", block: true))

// Forward references exercise the native figure anchors used by lines,
// highlights, and annotations. The language badge also includes its icon.
@code:1 @marked @note
#figure(caption: [Accessible code])[
  #codly.new(
    raw("fn main() {\n  return 1\n}", block: true, lang: "typ"),
    block-label: <code>,
    highlights: ((line: 1, label: <marked>),),
    annotations: ((start: 2, content: [Returns one], label: <note>),),
  )
]<code>

#{
  show: e.set_(codly.codly-number, placement: "outside")
  show: codly.line-set_(stroke: blue + 1pt)
  codly.new(raw("outside\nsecond", block: true), radius: 8pt, annotations: (
    (start: 1, end: 2, content: [Remark]),
  ))
}

#context {
  assert.eq(query(<code>).len(), 1)
  assert.eq(query(<marked>).len(), 1)
  assert.eq(query(<note>).len(), 1)
  assert.eq(query(figure.where(kind: "codly-line")).len(), 3)
}

// Guides are decorative strokes; source remains searchable accessible text.
#codly.new(raw("guided source\n    guided child", block: true), indent-guides: (
  rainbow: true,
  palette: (purple, blue),
))

// Continuation markers are decorative artifacts; the source remains text.
#codly.new(raw("wrapped source " + "argument " * 15, block: true), wrap-marker: [↪])
