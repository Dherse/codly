#import "../../codly.typ": *

#set page(width: 300pt, height: auto)
#show: codly-init.with()

#codly-skip(2, 4)
#codly(number-format: none)

```txt
a
b
c
d
e
f
g
```

#codly-skip(2, 4)
#codly(number-format: numbering.with("1"))
```txt
a
b
c
d
e
f
g
```