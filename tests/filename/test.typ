#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e
#set page(width: 300pt, height: auto, margin: 8pt)
#show: codly.line-set_(fill: white)

#let sample(key, body, ..args) = {
  show: codly.file-show_(it => [#metadata((key: key, fields: e.fields(it)))<filename>#it])
  show: codly.lang-show_(it => [#metadata((key: key, fields: e.fields(it)))<language>#it])
  show: codly.line-show_(it => {
    let line = e.fields(it).body
    if line.func() == raw.line { [#metadata((key: key, line: line))<source>#it] } else { it }
  })
  codly.new(body, ..args)
}
#sample("path", path("fixtures/hello.py"))
#sample("string", "print(1)", file: "snippet.py")
#sample("override", path("fixtures/hello.py"), file: "renamed.rs", lang: "js")
#sample("hidden", path("fixtures/hello.py"), file: none, lang-position: none)
#sample("auto-width", "print(1)", file: "main.py", width: auto)
#sample("raw", raw("print(1)", block: true, lang: "py"), file: [*Raw input*])
#sample("literal", "fixtures/hello.py", lang: none)
#sample("empty", "", file: "empty.txt", skip-last-empty: false)

#context {
  let files = query(selector(<filename>).before(here()))
  assert.eq(files.map(m => m.value.key), (
    "path",
    "string",
    "override",
    "auto-width",
    "raw",
    "empty",
  ))
  assert.eq(files.at(0).value.fields.body, "hello.py")
  assert.eq(files.at(2).value.fields.body, "renamed.rs")
  let langs = query(selector(<language>).before(here()))
  assert.eq(langs.map(m => m.value.fields.body), ("py", "py", "js", "py", "py", "txt"))
  let lines(key) = query(<source>).filter(m => m.value.key == key).map(m => m.value.line.text)
  assert.eq(lines("path").join("\n"), read("fixtures/hello.py").trim(at: end))
  assert.eq(lines("string"), ("print(1)",))
  assert.eq(lines("literal"), ("fixtures/hello.py",))
}

#pagebreak()
// All four corners for both badges; shared sides must not overlap.
#for (i, file-pos) in (top + left, top + right, bottom + left, bottom + right).enumerate() {
  for (j, lang-pos) in (top + left, top + right, bottom + left, bottom + right).enumerate() {
    sample(
      "corner-" + str(i) + str(j),
      "print(1)",
      file: "main.py",
      file-position: file-pos,
      lang-position: lang-pos,
      number-enabled: calc.even(i + j),
    )
  }
}
#context {
  for (i, file-pos) in (top + left, top + right, bottom + left, bottom + right).enumerate() {
    for (j, lang-pos) in (top + left, top + right, bottom + left, bottom + right).enumerate() {
      let key = "corner-" + str(i) + str(j)
      let file = query(<filename>).find(m => m.value.key == key).location().position()
      let lang = query(<language>).find(m => m.value.key == key).location().position()
      let source = query(<source>).find(m => m.value.key == key).location().position()
      if file-pos.y == top { assert(file.y < source.y) } else { assert(file.y > source.y) }
      if lang-pos.y == top { assert(lang.y < source.y) } else { assert(lang.y > source.y) }
      if file-pos.y == lang-pos.y {
        assert(calc.abs(file.y - lang.y) < 0.01pt, message: repr((key, file, lang)))
        if file-pos.x == right and lang-pos.x == left { assert(file.x > lang.x + 15pt) } else {
          assert(lang.x > file.x + 35pt)
        }
      }
    }
  }
}

#pagebreak()
// Inputs imported from another directory retain their caller-owned path root.
#import "fixtures/nested/input.typ": nested
#sample("nested", nested)
#sample("quoted", path("fixtures/échantillon \"test\".py"))
#sample("no-extension", path("fixtures/Makefile"))
#sample("hidden-file", "print(1)", file: "main.py", file-position: none)
#{
  show: codly.set_(file-position: bottom + right, lang-position: top + left)
  show: codly.file-set_(
    fill: gradient.linear(aqua, white),
    stroke: blue + 1pt,
    inset: (x: 10pt, y: 6pt),
    radius: (top-left: 8pt, bottom-right: 8pt),
  )
  sample("inherited-position", path("fixtures/hello.py"))
  sample(
    "styled",
    path("fixtures/hello.py"),
    header: [Custom header],
    footer: [Custom footer],
    file-position: top + right,
    aliases: (py: "python"),
    annotations: ((start: 1, end: 2, content: [Note]),),
    callouts: ((line: 2, pointer: 8, placement: "above", body: [Callout]),),
    indent-guides: true,
    rainbow: true,
  )
}
#sample("filename-only", "unknown source", file: "note.txt", lang: none)
#context {
  let find(key) = query(<filename>).find(m => m.value.key == key).value.fields
  assert.eq(find("nested").body, "hello.py")
  assert.eq(find("quoted").body, "échantillon \"test\".py")
  assert.eq(find("no-extension").body, "Makefile")
  assert.eq(query(<language>).filter(m => m.value.key == "no-extension").len(), 0)
  assert.eq(query(<filename>).filter(m => m.value.key == "hidden-file").len(), 0)
  assert.eq(find("styled").inset, (x: 10pt, y: 6pt))
  assert.eq(type(find("styled").fill), gradient)
  let inherited-file = query(<filename>)
    .find(m => m.value.key == "inherited-position")
    .location()
    .position()
  let inherited-lang = query(<language>)
    .find(m => m.value.key == "inherited-position")
    .location()
    .position()
  let inherited-source = query(<source>)
    .find(m => m.value.key == "inherited-position")
    .location()
    .position()
  assert(inherited-lang.y < inherited-source.y and inherited-file.y > inherited-source.y)
  assert.eq(query(<language>).find(m => m.value.key == "styled").value.fields.body, "py")
}
