#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#let example(code) = {
  table(
    columns: (1fr, .6fr),
    table.header[*Code*][*Result*],
    raw(block: true, lang: "typ", code.text),
    eval(code.text, mode: "markup", scope: (codly: codly)),
  )
}

#codly.new(
  ```
  this is a test
  ```,
  highlights: (
    (line: 1, start: 1, fill: green, tag: [Outer]),
    (line: 1, start: 6, end: 9, fill: red, tag: [Inner]),
  ),
)

#codly.new(
  ```
  this is a test
  ```,
  highlights: (
    (line: 1, start: 1, fill: green, tag: [Outer]),
    (line: 1, start: 6, fill: red, tag: [Inner]),
  ),
)
