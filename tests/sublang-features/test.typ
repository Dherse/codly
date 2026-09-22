#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 300pt, height: auto, margin: 5pt)

#let text-of(body) = {
  if body.has("text") { body.text } else if body.has("children") {
    body.children.map(text-of).join()
  } else if body.has("child") { text-of(body.child) } else if body.has("body") {
    text-of(body.body)
  } else { "" }
}

#show: codly.line-show_(it => {
  let fields = e.fields(it)
  let line = fields.body
  if line != none and line.func() == raw.line {
    [#metadata((
        number: line.number,
        count: line.count,
        text: line.text,
        body: text-of(line.body),
        styled: line.body,
        smart-indent: fields.smart-indent,
      ))<sublang-line>#it]
  } else {
    [#metadata(line)<sublang-skip>#it]
  }
})
#show: codly.highlight-show_(it => {
  let fields = e.fields(it)
  [#metadata((tag: fields.highlight.tag, body: text-of(fields.body)))<sublang-highlight>#it]
})
#show: e.show_(codly.codly-number, it => {
  [#metadata(e.fields(it).body)<sublang-number>#it]
})
#show: codly.annotation-show_(it => {
  let fields = e.fields(it)
  [#metadata((num: fields.num, height: fields.height))<sublang-annotation>#it]
})

// Both sublanguages participate in the SAME source-line loop: a hidden line,
// a smart skip, an explicit skip, offsets, nested highlights, and an annotation
// spanning the language boundary all retain their parent-block coordinates.
@mixed:12 @rust-mark @c-mark @mixed-note
#figure(caption: [Mixed languages])[
  #codly.new(
    raw(
      "echo before\n    let value = 1;\n    /* comment\n       continued */\necho middle\nint answer() {\n    return 42;\n}\n",
      lang: "sh",
      block: true,
    ),
    block-label: <mixed>,
    offset: 10,
    sublangs: ((start: 2, end: 4, lang: "rs"), (start: 6, end: 8, lang: "c")),
    ranges: ((1, 2), (4, none)),
    smart-skip: true,
    skips: ((7, 2),),
    skip-line: [gap],
    skip-number: [gap],
    highlights: (
      (line: 12, start: 4, end: 18, tag: "outer", label: <rust-mark>),
      (line: 12, start: 8, end: 13, tag: "inner"),
      (line: 19, start: 4, end: 10, tag: "return", label: <c-mark>, fill: blue),
    ),
    highlighted: ((19, yellow),),
    annotations: ((start: 2, end: 7, content: [span], label: <mixed-note>),),
  )
]<mixed>

// Reusing sublanguage index zero in later blocks must resolve their own text.
// Cover numbering disabled, offset-from, and a trailing empty sublanguage line.
#codly.new(
  raw("let other = 2;\n", lang: "sh", block: true),
  sublangs: ((start: 1, end: 2, lang: "rs"),),
  number-enabled: false,
  offset-from: <mixed>,
  smart-indent: false,
  highlights: ((line: 21, start: 1, end: 3, tag: "later"),),
)<later>

// Ordinary raw syntax gives a reference for the complete styled line content;
// copying a sublanguage must preserve it before applying line formatting.
#codly.new(raw("    let value = 1;", lang: "rs", block: true))
#codly.new(raw("    return 42;", lang: "c", block: true))

#context {
  let lines = query(<sublang-line>).map(it => it.value)
  assert.eq(lines.map(it => it.number), (11, 12, 14, 15, 16, 19, 20, 21, 1, 1))
  assert.eq(lines.slice(0, 7).map(it => it.count), (9, 9, 9, 9, 9, 9, 9))
  assert.eq(lines.at(1).text, "    let value = 1;")
  assert.eq(lines.at(2).text, "       continued */")
  assert.eq(lines.at(5).text, "    return 42;")
  assert.eq(lines.at(7).text, "let other = 2;")
  assert.eq(lines.at(7).smart-indent, false)
  for line in lines { assert.eq(line.body, line.text) }
  assert.eq(query(<sublang-skip>).map(it => it.value), ([gap], [gap]))
  assert.eq(query(<sublang-number>).map(it => it.value), (
    11,
    12,
    [gap],
    14,
    15,
    16,
    [gap],
    19,
    20,
    1,
    1,
  ))
  let annotations = query(<sublang-annotation>)
  assert.eq(annotations.map(it => it.value.num), (1,))
  // A figure's inherited block settings must not collapse the brace height.
  // It must cover the annotated rows, including highlights and both skips.
  let positions = query(<sublang-line>).slice(0, 7).map(it => it.location().position())
  let height = annotations.first().value.height
  assert(height >= positions.at(5).y - positions.at(1).y)
  assert(height <= positions.at(6).y - positions.at(0).y)

  let highlights = query(<sublang-highlight>).map(it => it.value)
  assert.eq(highlights.map(it => it.tag).sorted(), ("inner", "later", "outer", "return"))
  assert(highlights.find(it => it.tag == "inner").body.contains("value"))
  assert.eq(highlights.find(it => it.tag == "return").body, "    return")
  assert.eq(highlights.find(it => it.tag == "later").body, "let")

  assert.eq(lines.at(1).styled, lines.at(8).styled)
  assert.eq(lines.at(5).styled, lines.at(9).styled)
  for target in (<mixed:12>, <mixed:19>, <rust-mark>, <c-mark>, <mixed-note>) {
    assert.eq(query(target).len(), 1)
    assert.eq(query(target).first().func(), figure)
  }
  assert.eq(query(<mixed:13>).len(), 0)
  assert.eq(codly.info(<mixed>), (last-number: 20, lines: 9))
  assert.eq(codly.info(<later>), (last-number: 21, lines: 2))
}
