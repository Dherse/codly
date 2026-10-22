#import "../../codly.typ" as codly

#set page(width: 400pt, height: 600pt, margin: 20pt)

#show: codly.annotation-show_(it => {
  let fields = codly.e.fields(it)
  [#metadata(fields.height)<annotation-height>#it]
})

#metadata(none)<before-code>
#codly.new(
  ```py
  prepare()
  result = compute()
  print(result)
  cleanup()
  ```,
  annotations: ((
    start: 2,
    end: 4,
    content: [Computes and displays\ the result],
  ),),
)
#metadata(none)<after-code>

#context {
  let before = query(<before-code>).first().location().position()
  let after = query(<after-code>).first().location().position()
  assert.eq(after.page, before.page)
  assert(after.y - before.y < 100pt, message: "annotation must not expand the code to page height")
  let height = query(<annotation-height>).first().value
  assert(height > 0pt and height < 80pt, message: "brace must follow the source rows")
}

#show: codly.line-show_(it => {
  let body = codly.e.fields(it).body
  [#metadata(body.number)<source-line>#it]
})

#for (leading, row-gap, numbered, width) in (
  (none, 0pt, true, 100%),
  (5pt, 3pt, false, 100%),
  (2pt, 6pt, true, auto),
) {
  pagebreak()
  context {
    show: codly.line-set_(inset: (top: 2pt, bottom: 4pt, x: 3pt))
    let origin = here()
    codly.new(
      raw(range(1, 9).map(n => "line " + str(n)).join("\n"), block: true),
      leading: leading,
      row-gutter: row-gap,
      number-enabled: numbered,
      width: width,
      annotations: (
        (start: 1, end: 1, content: [Single]),
        (start: 3, end: 6, content: [Multiple\ lines]),
      ),
    )
    context {
      let lines = query(selector(<source-line>).after(origin).before(here()))
      let annotations = query(selector(<annotation-height>).after(origin).before(here()))
      let padding = if leading == none { 9pt } else { 3 * leading }
      assert.eq(annotations.len(), 2)
      for (annotation, start, after) in annotations.zip((1, 3), (2, 7)) {
        let first = lines.find(line => line.value == start).location().position()
        let next = lines.find(line => line.value == after).location().position()
        let expected = next.y - first.y - padding - row-gap
        assert((annotation.value - expected).abs < 0.1pt)
      }
    }
  }
}
