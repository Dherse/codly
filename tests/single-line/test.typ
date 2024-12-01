#import "../../codly.typ": *

#set page("a6")

#show: codly-init

```typst
Hello, world!
```

#codly-disable()
```typst
Hello, world!
```

#codly-enable()
```typst
Hello, world!
```

#codly(number-format: none)
```typst
Hello, world!
```

#codly(lang-format: none)
```typst
Hello, world!
```

#codly(annotations: ((start: 0, content: "Hello, world!"), ))
```typst
Hello, world!
```

#codly(lang-format: auto)
#codly(annotations: ((start: 0, content: "Hello, world!"), ))
```typst
Hello, world!
```

= With highlight
#codly(highlights: ((line: 0, tag: "Hello, world!"), ))
#codly(inset: 0.5pt)
```typst
Hello, world!
```

#no-codly[
  ```typst
  Hello, world!
  ```
]

#codly(inset: 10pt)
```typst
Hello, world!
```

#codly(inset: 0.5pt)
```typst
Hello, world!
```

#codly-reset()
#codly(languages: (py: (name: "Python", icon: "Sss ", color: rgb("#4584b6")), ))
```py
# Example code that calculates the sum of the first 10 natural numbers squares
```