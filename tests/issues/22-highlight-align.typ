#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#show: codly.lang-set_(
  display-icon: false,
  display-name: false,
)

#grid(columns: 3)[
  #codly.new(highlights: ((line: 2, start: 0, end: none),))[
    ```kotlin
    val n = 0
    val n = 0
    ```
  ]
][
  #show: codly.highlight-set_(
    inset: 0em,
    outset: 0.32em,
    clip: true,
  )

  #codly.new(highlights: ((line: 1, start: 0, end: none),))[
    ```kotlin
    val n = 0
    val n = 0
    ```
  ]
][
  #show: codly.highlight-set_(
    inset: 0em,
    outset: 0.32em,
    clip: true,
  )

  #codly.new(highlights: ((line: 2, start: 0, end: none),))[
    ```kotlin
    val n = 0
    val n = 0
    ```
  ]
]
