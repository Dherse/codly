#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 260pt, height: 160pt, margin: 8pt)
#show: codly.line-set_(fill: white)
#show: codly.header-set(repeat: true)
#show: e.set_(codly.footer, repeat: true)
#show: codly.file-show_(it => [#metadata(e.fields(it).body)<file>#it])
#show: codly.lang-show_(it => [#metadata(e.fields(it).body)<lang>#it])
#show: codly.line-show_(it => {
  let line = e.fields(it).body
  if line.func() == raw.line { [#metadata(line.text)<line>#it] } else { it }
})

// Repeated headers and footers retain badges while normal line rendering,
// filtering, offset numbering, and labels stay on the shared code path.
#let source = range(1, 25).map(i => "print(" + str(i) + ")").join("\n")
#figure(caption: [A file listing])[
  #codly.new(
    source,
    file: "long.py",
    file-position: top + left,
    lang-position: bottom + right,
    block-label: <listing>,
    header: [Repeated header],
    footer: [Repeated footer],
    range: (3, 22),
    offset: 10,
    highlights: ((line: 14, start: 0, end: 5),),
    callouts: ((line: 4, body: [A note]),),
  )
]<listing>
@listing:13

#context {
  assert(counter(page).final().first() > 1)
  let lines = query(<line>).map(m => m.value)
  assert.eq(lines, range(3, 23).map(i => "print(" + str(i) + ")"))
  assert(query(<file>).all(m => m.value == "long.py"))
  assert(query(<lang>).all(m => m.value == "py"))
  assert.eq(codly.info(<listing>).last-number, 32)
}
