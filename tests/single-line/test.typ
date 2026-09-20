#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 8cm + 10pt, height: auto, margin: 5pt)

#codly.new[```typst
Hello, world!
```]

#codly.new[```typst
Hello, world!
```]

#codly.new(number-enabled: false)[```typst
Hello, world!
```]

#{
  show: e.show_(codly.codly-lang, it => [])
  codly.new(number-enabled: false)[```typst
  Hello, world!
  ```]
}

#{
  show: e.show_(codly.codly-lang, it => [])
  codly.new(number-enabled: false, annotations: ((start: 1, content: "Hello, world!"),))[```typst
  Hello, world!
  ```]
}

#codly.new(number-enabled: false, annotations: ((start: 1, content: "Hello, world!"),))[```typst
Hello, world!
```]

= With highlight
#{
  show: codly.line-set_(inset: 0.5pt)
  codly.new(number-enabled: false, highlights: ((line: 1, tag: "Hello, world!"),))[```typst
  Hello, world!
  ```]
}

#{
  show: codly.lang-set_(languages: (
    py: (name: "Python", icon: "Sss ", color: rgb("#4584b6")),
  ))
  codly.new[```py
  # Example code that calculates the sum of the first 10 natural numbers squares
  ```]
}
