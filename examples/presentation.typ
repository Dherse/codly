#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("github-light")

#{
  show: codly.line-set_(fill: (rgb("f0f5ff"), white, rgb("f6f3ff")))
  show: codly.header-set_(fill: rgb("dce8ff"), align: left)
  show: codly.footer-set_(fill: rgb("eef2f8"), align: left)
  codly.new(
    raw(
      "const palette = [\n    \"ocean\",\n    \"forest\",\n    \"sunset\",\n];",
      lang: "js",
      block: true,
    ),
    file: "palette.js",
    header: [Available palettes],
    footer: [palette.js],
    padding: (x: 8pt, y: 6pt),
    radius: 7pt,
  )
}

#{
  show: codly.line-set_(fill: row => if row.kind == "code" and row.source-line == 2 {
    gradient.linear(rgb("e0f2fe"), rgb("ede9fe"))
  } else { white })
  codly.new(
    raw(
      "function active(items) {\n    return items.filter(item => item.ready);\n}",
      lang: "js",
      block: true,
    ),
    file: "filter.js",
    file-position: left,
    lang-position: right,
    header: [Select ready items],
    padding: 5pt,
  )
}
