#import "../../codly.typ": *

#set page(width: 300pt, height: auto)
#show: codly-init.with()

#codly(
  display-icon: false,
  display-name: false,
)

#grid(columns: 3)[
#codly(highlights: ((line: 2, start: 0, end: none), ))
```kotlin
val n = 0
val n = 0
```
][
  #codly(highlights: ((line: 1, start: 0, end: none), ))
  #local(
    highlight-inset: 0em,
    highlight-outset: 0.32em,
    highlight-clip: true,
  )[
    ```kotlin
val n = 0
val n = 0
    ```
    ]
][
  #codly(highlights: ((line: 2, start: 0, end: none), ))
  #local(
    highlight-inset: 0em,
    highlight-outset: 0.32em,
    highlight-clip: true,
  )[
    ```kotlin
val n = 0
val n = 0
    ```
  ]
]
