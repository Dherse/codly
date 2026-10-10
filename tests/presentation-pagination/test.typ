#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 300pt, height: 220pt, margin: 8pt)
#set text(size: 8pt)
#show: codly.theme("dark")
#show: codly.number-set_(placement: "outside")
#show: codly.callout-set_(source-indent: true)
#show: codly.line-show_(it => {
  [#metadata(e.fields(it).body.text)<paged-source>#it]
})
#let rows = range(1, 21).map(i => "    line " + str(i) + " wrapped source " * 5)
#codly.new(
  raw(rows.join("\n"), lang: "py", block: true),
  padding: (x: 8pt, y: 6pt),
  header: codly.header([Repeated header], repeat: true),
  footer: codly.footer([Repeated footer], repeat: true),
  highlighted: range(1, 21),
  indent-guides: (width: 4),
  wrap-marker: [↪],
  callouts: (
    (line: 2, body: [Indented explanation that wraps on narrow pages.]),
    (line: 10, body: [Middle note], placement: "above"),
    (line: 20, body: [Last note]),
  ),
)
#context {
  let marks = query(<paged-source>)
  assert.eq(marks.map(it => it.value), rows)
  assert(marks.map(it => it.location().position().page).dedup().len() > 1)
}
