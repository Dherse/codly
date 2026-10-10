#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("github-light")

#codly.new(
  raw(
    "def validate(record):\n    if not record.get(\"name\"):\n        return False\n    if record.get(\"age\", 0) < 18:\n        return False\n    return True",
    lang: "py",
    block: true,
  ),
  file: "validation.py",
  header: [Coverage · Line · Review],
  gutters: (
    (
      values: ("✓", "✓", "✓", "!", "!", "✓"),
      width: 18pt,
      align: center,
      fill: row => if row.source-line in (4, 5) { orange.lighten(85%) } else { green.lighten(90%) },
      text: (weight: "bold", fill: rgb("287d3c")),
    ),
    auto,
    (
      values: (none, none, none, "edge", "case", none),
      width: 30pt,
      align: left,
      text: (fill: rgb("9a6700")),
      fill: auto,
    ),
  ),
  highlighted: (4,),
)
