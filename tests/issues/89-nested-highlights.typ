#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#codly.new(
  highlights: (
    (line: 2, start: 10, end: 10, fill: green),
    (line: 2, start: 14, end: 14, fill: red),
    (line: 2, start: 10, end: 14, fill: blue),
  ),
  ```py
  def add(x, y):
    return x + y
  ```,
)
