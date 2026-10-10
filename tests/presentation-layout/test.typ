#import "../../codly.typ" as codly

#set page(width: 390pt, height: auto, margin: 10pt)
#set text(size: 9pt)
#let source = "def process(items):\n    for item in items:\n        if item.ready:\n            save(item)\n    return len(items)"
#for name in ("thesis", "dark", "clean", "github-light", "solarized-light", "one-light") {
  show: codly.theme(name)
  show: codly.callout-set_(source-indent: true)
  codly.new(
    raw(source, lang: "py", block: true),
    padding: (y: 5pt, x: 8pt),
    header: [#name],
    highlighted: (1, 2, 3, 4, 5),
    callouts: ((line: 3, body: [Only ready items are persisted.]),),
  )
}
#pagebreak()
#{
  show: codly.number-set_(placement: "outside")
  show: codly.line-set_(stroke: blue + 0.8pt)
  show: codly.callout-set_(source-indent: true)
  codly.new(
    raw(source, lang: "py", block: true),
    padding: (top: 10pt, bottom: 14pt, left: 16pt, right: 12pt),
    header: [Outside gutters and source-indented notes],
    footer: [Footer],
    radius: 8pt,
    gutters: (auto, (values: ("", "loop", "if", "save", ""), fill: none)),
    annotations: ((start: 2, end: 4, content: [loop]),),
    indent-guides: (width: 4),
    wrap-marker: [↪],
    highlighted: (3,),
    callouts: (
      (line: 3, placement: "above", body: [Automatically aligned to the condition.]),
      (
        line: 4,
        body: [A longer explanation that wraps, keeping its continuation aligned to the source indentation and clear of the gutters.],
      ),
      (line: 5, body: [Full-width opt-out.], source-indent: false),
      (line: 2, pointer: 9, body: [Pointed bubble is unchanged.]),
    ),
  )
}
#codly.new(
  raw("first\nsecond\nthird\nfourth\nfifth\nsixth", block: true),
  padding: 8pt,
  highlights: (
    (line: 1, tag: "a"),
    (line: 2, tag: "b"),
    (line: 3, tag: "c"),
    (line: 4, tag: "d"),
    (line: 5, tag: "e"),
    (line: 6, tag: "a again"),
  ),
)
