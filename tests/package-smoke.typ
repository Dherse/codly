// Compile against the built package, without checkout imports or development assets.
#import "/codly.typ" as codly
#set page(width: 400pt, height: auto, margin: 10pt)
#show: codly.theme("dark")
#show: codly.number-set_(numbering: "I.")
#codly.new(
  raw("def example():\n    return [1, 2]", lang: "py", block: true),
  file: "example.py",
  rainbow: true,
  highlights: ((line: 1, fill: color => color),),
  callouts: ((line: 2, body: [Packaged callout]),),
  annotations: ((start: 1, numbering: none, content: [Packaged annotation]),),
)
#codly.new(raw("-return 1\n+return 2", lang: "diff,py", block: true))
#codly.new(raw("#let x = 1", lang: "typ", block: true))
