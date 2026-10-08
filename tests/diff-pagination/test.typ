#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 280pt, height: 200pt, margin: 8pt)
#set text(size: 8pt)
#show: codly.number-set_(placement: "outside")
#show: codly.line-show_(it => {
  let row = e.fields(it).body
  [#metadata(row.text)<diff-paged-row>#it]
})
#let rows = range(1, 26).map(i => str(i) + ": long wrapped source " + "argument " * 5)
#codly.new(
  raw(
    rows.enumerate().map(((i, row)) => (if calc.odd(i) { "+" } else { "-" }) + row).join("\n"),
    lang: "diff,py",
    block: true,
  ),
  header: codly.header([Repeated diff header], repeat: true),
  footer: codly.footer([Repeated diff footer], repeat: true),
  annotations: ((start: 3, end: 20, content: [changes]),),
  wrap-marker: [↪],
  radius: 8pt,
)
#context {
  let marks = query(<diff-paged-row>)
  assert.eq(marks.map(it => it.value), rows)
  assert(marks.map(it => it.location().position().page).dedup().len() > 1)
}
