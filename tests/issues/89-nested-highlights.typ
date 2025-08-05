#import "../../codly.typ": *


#show: codly-init

#codly(highlights: (
  (line: 2, start: 10, end: 10, fill: green),
  (line: 2, start: 14, end: 14, fill: red),
  (line: 2, start: 10, end: 14, fill: blue),
))
```py
def add(x, y):
  return x + y
```