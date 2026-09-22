#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#let mark(name) = [#metadata(name)<baseline>word]
#let sample(highlight: none) = [
  #box(mark("plain")) #codly.codly-highlight(mark("highlight"), highlight: highlight)
  #parbreak()
]

#sample()
#sample(highlight: (line: 1, inset: (top: 2pt, bottom: 5pt)))
#sample(highlight: (line: 1, tag: [tag]))
#sample(highlight: (line: 1, baseline: 3pt))
#sample(highlight: (line: 1, baseline: auto))

#{
  show: codly.highlight-set_(baseline: auto)
  sample()
}

// Issue #131 / PR #132, rendered through the complete raw-line pipeline.
#codly.new(highlights: ((line: 3, start: 3, end: 10, fill: orange),), raw(
  "pub fn main() {\n  println!(\"Hello!\");\n  println!(\"Hello!\");\n}",
  lang: "rust",
  block: true,
))

#context {
  let marks = query(<baseline>)
  assert.eq(marks.len(), 12)
  for i in range(0, marks.len(), step: 2) {
    let shift = marks.at(i).location().position().y - marks.at(i + 1).location().position().y
    assert.eq(shift, if i == 6 { -3pt } else { 0pt })
  }
}
