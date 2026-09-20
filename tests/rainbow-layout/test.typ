#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 190pt, height: 100pt, margin: 5pt)
#show: e.set_(codly.codly-number, placement: "outside", fill: none)
#show: codly.line-set_(stroke: 0.6pt + black)

#let source = ("f({value: [1, 2, 3]});\n" * 8).trim()
#for enabled in (false, true) {
  if enabled { pagebreak() }
  show: codly.line-show_(it => [#metadata((enabled, e.fields(it).body.number))<row>#it])
  codly.new(raw(source, lang: "js", block: true), rainbow: enabled, header: [head], radius: 4pt)
}

#context {
  let runs = ((), ())
  for row in query(<row>) {
    let index = if row.value.first() { 1 } else { 0 }
    runs.at(index).push((row.value.last(), row.location().position()))
  }
  assert.eq(runs.first().len(), 8)
  assert.eq(runs.last().len(), 8)
  for run in runs { assert(run.last().last().page > run.first().last().page) }
  let page-offset = runs.last().first().last().page - runs.first().first().last().page
  for (before, after) in runs.first().zip(runs.last()) {
    assert.eq(before.first(), after.first())
    let a = before.last()
    let b = after.last()
    assert.eq((a.x, a.y, a.page + page-offset), (b.x, b.y, b.page))
  }
}
