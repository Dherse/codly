#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("github-light")

#let source = "import json\n\ndef load(path):\n    with open(path) as stream:\n        data = json.load(stream)\n    return data\n\ndef count(path):\n    return len(load(path))"
#codly.new(
  raw(source, lang: "py", block: true),
  file: "loader.py",
  header: [Original source coordinates],
  ranges: ((3, 6), (8, 9)),
  smart-skip: true,
)<original>
#codly.new(
  raw(source, lang: "py", block: true),
  header: [The same excerpt, renumbered],
  range: (3, 6),
  offset: auto,
)<excerpt>
#codly.new(
  raw("print(count(\"records.json\"))", lang: "py", block: true),
  header: [Continue from the excerpt],
  offset: <excerpt>,
)
