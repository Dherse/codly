#import "../../codly.typ" as codly

#set page(width: 220pt, height: auto, margin: 5pt)

// Alias reconstruction must not apply this relative block rule twice.
#show raw.line: it => context [
  #metadata((text: it.text, height: measure(it.body).height))<alias-line-height>
  #it
]
#{
  show: codly.set_(aliases: (cuda: "c++"))
  show raw: set text(font: "DejaVu Sans Mono", fill: red)
  show raw: set text(0.9em)
  show raw.where(block: true): set text(0.8em)

  codly.new(raw("alias", lang: "cuda", block: true))
  codly.new(raw("direct", lang: "cpp", block: true))
}

#context {
  let lines = query(<alias-line-height>)
    .map(it => it.value)
    .filter(it => it.text in ("alias", "direct"))
  assert.eq(lines.len(), 2)
  assert.eq(lines.first().height, lines.last().height)
}

#pagebreak()
#include "99-local-resources.typ"
