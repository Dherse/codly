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

// Reconstructed aliases and diffs retain the already-resolved raw text size,
// including show-rule input, relative raw rules, and a scoped syntax theme.
#for theme in ("thesis", "dark") {
  for size in (11pt, 15pt) {
    set text(size: size)
    show: codly.theme(theme)
    show raw: set text(0.9em)
    show raw.where(block: true): set text(0.8em)
    show text: it => context {
      if it.text == "return" {
        [#metadata((theme: theme, size: size, actual: text.size))<reconstructed-size>]
      }
      it
    }
    codly.new(raw("return value", lang: "py", block: true))
    codly.new(raw("return value", lang: "custom", block: true), aliases: (custom: "py"))
    codly.new(raw("+return value", lang: "diff-py", block: true))
    {
      show raw.where(block: true): codly.new.with(aliases: (custom: "py"))
      raw("return value", lang: "custom", block: true)
      raw("+return value", lang: "diff-py", block: true)
    }
  }
}
#context {
  let sizes = query(<reconstructed-size>).map(it => it.value)
  assert.eq(sizes.len(), 20)
  for sample in sizes {
    assert(calc.abs(sample.actual - sample.size * 0.8 * 0.9 * 0.8) < 0.0001pt)
  }
}
