#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame

#let source = "def double(value):\n    # Preserve the input type.\n    return value * 2"
#grid(columns: (1fr, 1fr), gutter: 6pt, ..codly
    .themes
    .keys()
    .map(name => {
      show: codly.theme(name)
      codly.new(raw(source, lang: "py", block: true), header: [#name], highlights: (
        (line: 3, start: 12, end: 20),
      ))
    }))
