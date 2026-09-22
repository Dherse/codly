#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#show: codly.highlight-set_(inset: (x: 0.2em, y: 0pt))
#codly.new(
  highlights: ((line: 1, tag: "(1)"),),
  ```
  code
  ```,
)
