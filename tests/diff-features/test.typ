// Two-view parsing and rendering behavior, independent of visual snapshots.
#import "../../codly.typ" as codly
#import "../../src/diff.typ" as impl
#import "@preview/elembic:1.1.1" as e

#set page(width: 400pt, height: auto, margin: 6pt)

#assert.eq(impl.language("py"), none)
#assert.eq(impl.language("diff, py"), "py")
#let model = impl.parse(" shared\n-old\n+new\n-\n+\n++literal\n--literal\n  indented")
#assert.eq(model.rows.map(row => row.kind), (
  "context",
  "removed",
  "added",
  "removed",
  "added",
  "added",
  "removed",
  "context",
))
#assert.eq(model.groups.first().old, ("shared", "old", "", "-literal", " indented"))
#assert.eq(model.groups.first().new, ("shared", "new", "", "+literal", " indented"))
#assert.eq(model.rows.map(row => row.old), (1, 2, none, 3, none, none, 4, 5))
#assert.eq(model.rows.map(row => row.new), (1, none, 2, none, 3, 4, none, 5))
#assert.eq(impl.parse("-a\r\n+b\rc").groups.first(), (old: ("a", "c"), new: ("b", "c")))
#assert.eq(impl.parse("-a\n\\ No newline at end of file\n+b").groups.first(), (
  old: ("a",),
  new: ("b",),
))

#let patch = "diff --git a/a.c b/a.c\n--- a/a.c\n+++ b/a.c\n@@ -10,2 +20,2 @@ example\n-int old = 0;\n+int fresh = 1;\n return 2;\n@@ -30,0 +40,1 @@\n+int last = 3;\n\\ No newline at end of file"
#let parsed = impl.parse(patch)
#assert.eq(parsed.groups, (
  (old: ("int old = 0;", "return 2;"), new: ("int fresh = 1;", "return 2;")),
  (old: (), new: ("int last = 3;",)),
))
#assert.eq(parsed.rows.filter(row => row.group != none).map(row => (row.old, row.new)), (
  (10, none),
  (none, 20),
  (11, 21),
  (none, 40),
))

// A removed multiline comment must not affect new-side syntax. Conversely,
// its closing delimiter must retain old-side comment highlighting.
#let old = "/* start\n shared\nend */\nint stable = 3;"
#let new = "int added = 1;\n shared\nint later = 2;\nint stable = 3;"
#let source = "-/* start\n+int added = 1;\n  shared\n-end */\n+int later = 2;\n int stable = 3;"
#show: codly.line-show_(it => {
  let row = e.fields(it)
  if row.body.func() == raw.line {
    [#metadata((text: row.body.text, body: row.body.body))<visible-line>#it]
  } else { it }
})
#codly.new(raw(old, block: true, lang: "c"))
#codly.new(raw(new, block: true, lang: "c"))
#codly.new(raw(source, block: true, lang: "diff,c"))
#context {
  let rows = query(selector(<visible-line>).before(here())).map(it => it.value)
  assert.eq(rows.len(), 14)
  let expected = (rows.at(0), rows.at(4), rows.at(5), rows.at(2), rows.at(6), rows.at(7))
  assert.eq(rows.slice(8), expected)
  let passes = query(selector(<__codly-diff-pass>).before(here())).map(it => it.value)
  assert.eq(passes.len(), 2)
  assert.eq(passes.at(0).lines.map(line => line.text).join("\n"), old)
  assert.eq(passes.at(1).lines.map(line => line.text).join("\n"), new)
}

#codly.new(raw(patch, lang: "diff,c", block: true))

// Full patches keep headers out of the syntax passes and isolate hunks.
#context {
  let passes = query(selector(<__codly-diff-pass>).before(here())).map(it => it.value)
  assert.eq(passes.len(), 5)
  assert.eq(passes.slice(2).map(it => it.lines.map(line => line.text)), (
    parsed.groups.at(0).old,
    parsed.groups.at(0).new,
    parsed.groups.at(1).new,
  ))
}

// Configuration casting, suppression, and source-number offsets.
#let (ok, off) = e.types.cast(false, codly.diff)
#assert(ok)
#assert.eq(e.fields(off).enabled, false)
#assert.eq(
  impl.parse("-old\n+new", old-offset: 9, new-offset: 19).rows.map(row => (row.old, row.new)),
  ((10, none), (none, 20)),
)
#let settings = e.fields(codly.diff(added-fill: row => {
  assert.eq(row.diff.kind, "added")
  assert.eq(row.diff.new, 2)
  assert.eq(row.text, "new")
  purple
}))
#assert.eq(
  impl.fill((kind: "code", source-line: 3, text: "new"), (rows: model.rows, settings: settings)),
  purple,
)
#assert.eq(
  impl.fill((kind: "skip", source-line: none), (rows: model.rows, settings: settings)),
  auto,
)
#assert.eq(impl.fill((kind: "code", source-line: 1), (rows: model.rows, settings: settings)), auto)

#{
  show: codly.line-show_(it => {
    [#metadata(e.fields(it).body.text)<disabled-line>#it]
  })
  codly.new(raw("-old\n+new", block: true, lang: "diff,py"), diff: false)
  codly.new(raw("-old\n+new", block: true, lang: "diff,py"), diff: none)
  codly.new(raw("-literal", block: true, lang: "diff,"), diff: false)
}
#context {
  assert.eq(query(<disabled-line>).map(it => it.value), (
    "-old",
    "+new",
    "-old",
    "+new",
    "-literal",
  ))
}

// Tab expansion must match an ordinary marker-free raw block exactly.
#{
  show: codly.line-show_(it => {
    let row = e.fields(it).body
    [#metadata((row.text, row.body))<tab-line>#it]
  })
  codly.new(raw("\treturn 1;", lang: "c", block: true, tab-size: 4))
  codly.new(raw("+\treturn 1;", lang: "diff,c", block: true, tab-size: 4))
}
#context {
  let rows = query(<tab-line>).map(it => it.value)
  assert.eq(rows.first(), rows.last())
}

// Source rows govern ordinary Codly coordinates; automatic old/new gutters
// are separate. References and callouts are emitted only by the merged block.
#figure(caption: [Diff coordinates])[
  #codly.new(
    raw(" shared\n-old\n+new\n tail", lang: "diff,py", block: true),
    block-label: <diff-coordinates>,
    offset: 10,
    range: (2, 4),
    smart-skip: true,
    highlights: ((line: 13, start: 1, end: 3, tag: "new", label: <diff-highlight>),),
    callouts: ((line: 2, pointer: 3, body: [note]),),
    annotations: ((start: 2, end: 3, content: [change]),),
  )
]<diff-coordinates>
#context {
  assert.eq(query(<diff-coordinates:12>).len(), 1)
  assert.eq(query(<diff-coordinates:13>).len(), 1)
  assert.eq(query(<diff-highlight>).len(), 1)
  assert.eq(codly.info(<diff-coordinates>), (last-number: 14, lines: 4))
}

// Actual cell fills: explicit whole-row highlights win; auto restores the
// ordinary palette; none removes paint; gradients and callbacks are supported.
#{
  let gradient-fill = gradient.linear(red.lighten(80%), orange.lighten(80%))
  show: codly.line-set_(fill: (yellow, aqua))
  show grid.cell: it => [#metadata((x: it.x, y: it.y, fill: it.fill))<diff-fill>#it]
  codly.new(
    raw("-old\n+new\n shared\n+explicit", block: true, lang: "diff,py"),
    highlighted: ((4, blue),),
    diff: (
      removed-fill: gradient-fill,
      added-fill: row => {
        assert.eq(row.kind, "code")
        assert.eq(row.source-line, 2)
        assert.eq(row.diff.new, 1)
        green
      },
      context-fill: auto,
    ),
  )
  codly.new(raw("-clear", block: true, lang: "diff,py"), gutters: (), diff: (removed-fill: none))
  context {
    let cells = query(<diff-fill>).map(it => it.value)
    assert.eq(cells.len(), 17)
    for x in range(4) {
      assert.eq(repr(cells.find(it => it.x == x and it.y == 0).fill), repr(gradient-fill))
      assert.eq(cells.find(it => it.x == x and it.y == 1).fill, green)
      assert.eq(cells.find(it => it.x == x and it.y == 2).fill, yellow)
      assert.eq(cells.find(it => it.x == x and it.y == 3).fill, blue)
    }
    assert.eq(cells.last().fill, none)
  }
}

// Custom gutters replace automatic columns; disabled numbering still keeps
// markers, and per-feature toggles can remove every automatic column.
#{
  show grid.cell: it => [#metadata(it.x)<diff-column>#it]
  codly.new(raw("+one", lang: "diff,py", block: true), number-enabled: false)
  codly.new(raw("+two", lang: "diff,py", block: true), diff: (numbers: false, markers: false))
  codly.new(raw("+three", lang: "diff,py", block: true), gutters: ((values: ("custom",)),))
}
#context { assert.eq(query(<diff-column>).map(it => it.value), (0, 1, 0, 0, 1)) }

// Reconstructed raws preserve local resources and relative font sizing.
#{
  set raw(
    theme: "../aliases/99-local-resources.tmTheme",
    syntaxes: "../aliases/99-local-resources.sublime-syntax",
  )
  show raw: set text(0.9em)
  show raw.where(block: true): set text(0.8em)
  show text.where(text: "keyword"): it => context [#metadata(text.fill)<diff-resource-color>#it]
  show raw.line: it => context [#metadata(measure(it.body).height)<diff-resource-height>#it]
  codly.new(raw("keyword", lang: "codly-alias-test", block: true))
  codly.new(raw("+keyword", lang: "diff,codly-alias-test", block: true))
  codly.new(raw(
    "+keyword",
    lang: "diff,codly-alias-test",
    block: true,
    theme: path("../aliases/99-local-resources.tmTheme"),
    syntaxes: path("../aliases/99-local-resources.sublime-syntax"),
  ))
  codly.new(raw(
    "+keyword",
    lang: "diff,codly-alias-test",
    block: true,
    theme: read("../aliases/99-local-resources.tmTheme", encoding: none),
    syntaxes: read("../aliases/99-local-resources.sublime-syntax", encoding: none),
  ))
}
#context {
  assert.eq(query(<diff-resource-color>).map(it => it.value), (rgb("ff0000"),) * 4)
  let heights = query(<diff-resource-height>).map(it => it.value)
  assert.eq(heights.len(), 4)
  assert.eq(heights, (heights.first(),) * 4)
}

// Aliases and sublanguages work independently in both views.
#{
  show: codly.set_(aliases: (custom-c: "c"))
  show: codly.line-show_(it => {
    let row = e.fields(it).body
    [#metadata((row.text, row.body))<diff-sublang>#it]
  })
  codly.new(raw("/* old */", lang: "c", block: true))
  codly.new(raw("return 1;", lang: "c", block: true))
  codly.new(raw("-/* old */\n+return 1;", lang: "diff,custom-c", block: true))
  codly.new(raw("-/* old */\n+return 1;", lang: "diff,sh", block: true), sublangs: (
    (start: 1, end: 2, lang: "c"),
  ))
}
#context {
  let rows = query(<diff-sublang>).map(it => it.value)
  assert.eq(rows.len(), 6)
  assert.eq(rows.slice(2, 4), rows.slice(0, 2))
  assert.eq(rows.slice(4, 6), rows.slice(0, 2))
}

// Rainbow bracket stacks must also use the separate old/new source views.
#{
  show: codly.line-show_(it => {
    let row = e.fields(it).body
    [#metadata((row.text, row.body))<diff-rainbow>#it]
  })
  codly.new(raw("f(\n  old([1])\n)", lang: "py", block: true), rainbow: true)
  codly.new(raw("f(\n  fresh({2: 3})\n)", lang: "py", block: true), rainbow: true)
  codly.new(
    raw(" f(\n-  old([1])\n+  fresh({2: 3})\n )", lang: "diff,py", block: true),
    rainbow: true,
  )
}
#context {
  let rows = query(<diff-rainbow>).map(it => it.value)
  assert.eq(rows.len(), 10)
  assert.eq(rows.slice(6), (rows.at(3), rows.at(1), rows.at(4), rows.at(5)))
}

// The automatic columns use patch old/new numbers, not the display offset or
// unnumbered setting. Explicit gutters and markers stay in their own scope.
#{
  show: codly.show_(it => {
    let fields = e.fields(it)
    if fields.__diff != none {
      [#metadata(fields.gutters.map(column => e.fields(column).values))<diff-gutters>#it]
    } else { it }
  })
  codly.new(
    raw(" shared\n-old\n+new", lang: "diff,py", block: true),
    offset: 50,
    unnumbered: ((2, [u]),),
    diff: (old-offset: 9, new-offset: 19, added-marker: [A], removed-marker: [R]),
  )
}
#context {
  assert.eq(query(<diff-gutters>).map(it => it.value), (
    ((10, 11, none), (20, none, 21), (none, [R], [A])),
  ))
}

// Switching themes restores automatic light defaults, and explicit diff
// configurations still override a preset's dark colors.
#{
  show: codly.theme("dark")
  e.get(get => {
    assert.eq(get(codly.codly).__diff-colors.added-fill, rgb("173b25"))
    []
  })
  {
    show: codly.theme("github-light")
    e.get(get => {
      assert.eq(get(codly.codly).diff, auto)
      assert.eq(get(codly.codly).__diff-colors, (:))
      []
    })
    codly.new(raw("+light", lang: "diff,py", block: true))
  }
  codly.new(raw("+custom", lang: "diff,py", block: true), diff: (added-fill: yellow))
}

#{
  show: codly.set_(diff: false)
  show: codly.theme("dark")
  e.get(get => {
    assert.eq(e.fields(get(codly.codly).diff).enabled, false)
    []
  })
  codly.new(raw("-literal", lang: "diff,py", block: true))
}

// Missing context cannot supply syntax state; each hunk and file starts a new
// pair of syntax views instead of leaking an open comment into later code.
#{
  show: codly.line-show_(it => {
    let line = e.fields(it).body
    [#metadata((line.text, line.body))<diff-hunk-line>#it]
  })
  codly.new(raw("return 1;", lang: "c", block: true))
  codly.new(raw(
    "diff --git a/a.c b/a.c\n--- a/a.c\n+++ b/a.c\n@@ -1 +1 @@\n-/* old\n+/* new\n@@ -10 +10 @@\n return 1;\ndiff --git a/b.c b/b.c\n--- a/b.c\n+++ b/b.c\n@@ -1,0 +1 @@\n+return 1;",
    lang: "diff,c",
    block: true,
  ))
}
#context {
  let rows = query(<diff-hunk-line>).map(it => it.value).filter(it => it.first() == "return 1;")
  assert.eq(rows.len(), 3)
  assert.eq(rows, (rows.first(),) * 3)
}
