#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 220pt, height: 110pt, margin: 6pt, columns: 2)
#set text(size: 7pt)
#show: codly.number-set_(placement: "outside", fill: none)
#show: codly.line-set_(stroke: purple + 1pt)

#codly.new(
  raw(
    range(1, 26).map(n => "line " + str(n) + if n == 3 { " wrapped " * 15 } else { "" }).join("\n"),
    block: true,
  ),
  gutters: (
    auto,
    codly.gutter-column(
      values: row => [#metadata(row.source-line)<paged-gutter>#row.source-line],
      fill: (yellow.lighten(70%), aqua.lighten(80%)),
      align: center,
    ),
    (values: range(1, 26), fill: none),
  ),
  header: codly.header([Repeated header], repeat: true),
  footer: codly.footer([Repeated footer], repeat: true, fill: luma(240)),
  annotations: ((start: 3, end: 20, content: [span]),),
  wrap-marker: [↪],
  radius: 8pt,
)

#context {
  let marks = query(<paged-gutter>)
  assert.eq(marks.map(it => it.value), range(1, 26))
  assert(marks.map(it => it.location().position().page).dedup().len() > 1)
}
