#import "../../codly.typ": *

#set page(width: 300pt, height: 300pt)
#show: codly-init.with()
#codly(
  enabled: true,
  annotations: (
    (start: 1),
    (start: 3),
    (start: 4), // If you replace it with `start: 5`, it works as expected.
    (start: 7),
    (start: 9),
  ),
)
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
```