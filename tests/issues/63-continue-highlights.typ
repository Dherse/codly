#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#codly.new(
  annotations: (
    (start: 1),
    (start: 3),
    (start: 4), // If you replace it with `start: 5`, it works as expected.
    (start: 7),
    (start: 9),
  ),
  ```
  a
  b
  c
  d
  e
  f
  g
  h
  i
  ```,
)
