#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 285pt, height: auto, margin: 5pt)

#let text-of(body) = {
  if body.has("text") {
    body.text
  } else if body.has("child") {
    text-of(body.child)
  } else if body.has("children") {
    body.children.map(text-of).join()
  } else {
    ""
  }
}

#let languages = (python: (name: [Python], color: red, icon: "P"))

// Element-level rules receive resolved fields and are scoped to their block.
#{
  show: codly.set_(radius: 7pt)
  show: codly.show_(it => {
    let fields = e.fields(it)
    [#metadata((
        radius: fields.radius,
        body-block: fields.body.fields().at("block", default: false),
      ))<codly-fields>#it]
  })
  show raw: it => {
    if it.text == "inline" {
      [#metadata(it.block)<inline-raw>#it]
    } else {
      it
    }
  }
  codly.new(raw("disabled", block: true))
  codly.new(raw("inline"))
}
#{
  show: codly.show_(it => {
    let fields = e.fields(it)
    [#metadata((radius: fields.radius))<codly-override>#it]
  })
  codly.new(raw("enabled", block: true))
}

// selector() matches codly instances, while show_() transforms all codly
// instances in its scope.
#{
  show codly.selector(): it => {
    let fields = e.fields(it)
    [#metadata(true)<selector-hit>#it]
  }
  codly.new(raw("selected", block: true))
  codly.new(raw("other", block: true))
}

// Language definitions and aliases are passed through to the language badge
// and syntax raw block respectively.
#{
  show: codly.lang-set_(languages: languages)
  show: codly.lang-show_(it => {
    let fields = e.fields(it)
    [#metadata((body: fields.body, python: fields.languages.python.name))<language-fields>#it]
  })
  show: codly.show_(it => {
    let fields = e.fields(it)
    let body-fields = if fields.body.func() == raw { fields.body.fields() } else { (:) }
    [#metadata(body-fields.at("lang", default: none))<language-raw>#it]
  })
  show: codly.line-show_(it => {
    let fields = e.fields(it)
    [#metadata(repr(fields.body.body))<language-syntax>#it]
  })
  codly.new(raw("let x = 1", block: true, lang: "python"))
  codly.new(
    raw("let x = 1", block: true, lang: "custom"),
    aliases: (custom: "python"),
  )
}

// Language badge visibility is independently configurable, and unknown keys
// fall back to their raw language name.
#{
  show: codly.lang-set_(languages: languages, display-name: false, display-icon: false)
  show: codly.lang-show_(it => {
    let fields = e.fields(it)
    [#metadata((
        body: fields.body,
        display-name: fields.display-name,
        display-icon: fields.display-icon,
      ))<language-hidden>#it]
  })
  codly.new(raw("hidden", block: true, lang: "python"))
}
#{
  show: codly.lang-set_(languages: languages)
  show: codly.lang-show_(it => {
    let fields = e.fields(it)
    [#metadata((
        body: fields.body,
        defined: fields.languages.at("missing", default: none),
      ))<language-fallback>#it]
  })
  codly.new(raw("missing", block: true, lang: "missing"))
}

// Plain header/footer content and pre-built element instances both retain
// their public fields when codly constructs the block grid.
#{
  show: e.show_(codly.codly-header, it => {
    let fields = e.fields(it)
    [#metadata((body: fields.body, fill: fields.fill))<header-hook>#it]
  })
  show: e.show_(codly.codly-footer, it => {
    let fields = e.fields(it)
    [#metadata((body: fields.body, fill: fields.fill))<footer-hook>#it]
  })
  codly.codly-header([standalone-head], fill: red)
  codly.codly-footer([standalone-foot], fill: blue)
  codly.new(raw("one", block: true), header: [plain-head], footer: [plain-foot])
  codly.new(
    raw("two", block: true),
    header: codly.codly-header([element-head], fill: red),
    footer: codly.codly-footer([element-foot], fill: blue),
  )
}

// Header/footer set rules provide defaults for plain content; explicit
// element fields override those defaults in the resulting grid cells.
#{
  show: codly.header-set(fill: green)
  show: e.set_(codly.codly-footer, fill: green)
  show grid: it => {
    let edges = ()
    for child in it.children {
      if child.func() == grid.header or child.func() == grid.footer {
        let cell = child.fields().children.first()
        edges.push((
          kind: if child.func() == grid.header { "header" } else { "footer" },
          fill: cell.fields().fill,
        ))
      }
    }
    [#metadata(edges)<styled-cells>#it]
  }
  codly.new(raw("style-one", block: true), header: [plain-header], footer: codly.codly-footer(
    [explicit-footer],
    fill: blue,
  ))
  codly.new(
    raw("style-two", block: true),
    header: codly.codly-header([explicit-header], fill: red),
    footer: [plain-footer],
  )
  codly.new(
    raw("style-three", block: true),
    header: codly.codly-header([inherited-header]),
    footer: codly.codly-footer([inherited-footer]),
  )
}

// Custom hooks can inspect line, number, highlight, and annotation elements.
#{
  show: codly.line-show_(it => {
    let fields = e.fields(it)
    [#metadata((number: fields.body.number, smart-indent: fields.smart-indent))<lines-seen>#it]
  })
  show: e.show_(codly.codly-number, it => {
    [#metadata(e.fields(it).body)<numbers-seen>#it]
  })
  show: codly.highlight-show_(it => {
    let fields = e.fields(it)
    [#metadata((body: fields.body, color: fields.color))<highlights-seen>#it]
  })
  show: codly.annotation-show_(it => {
    let fields = e.fields(it)
    [#metadata((body: fields.body, num: fields.num))<annotations-seen>#it]
  })
  codly.new(
    raw("abc\ndef", block: true),
    highlights: ((line: 1, start: 0, end: 2),),
    annotations: ((start: 2, content: [note]),),
  )
}

// Gradient and pattern fills exercise the main grid fill path.
#{
  show: codly.line-set_(fill: gradient.linear(red, blue))
  codly.new(raw("gradient", block: true))
}
#{
  show: codly.line-set_(fill: tiling(size: (4pt, 4pt), relative: "parent", rect(
    width: 2pt,
    height: 2pt,
  )))
  codly.new(raw("pattern", block: true))
}

#context {
  assert.eq(query(<codly-fields>).first().value, (radius: 7pt, body-block: true))
  assert.eq(query(<inline-raw>).first().value, false)
  assert.eq(query(<codly-override>).first().value, (radius: 0.32em))
  assert.eq(query(<selector-hit>).map(it => it.value), (true, true))
  assert.eq(query(<language-fields>).map(it => it.value.body), ("python", "custom"))
  assert.eq(query(<language-fields>).first().value.python, [Python])
  assert.eq(query(<language-raw>).map(it => it.value), ("python", "custom", "python"))
  let syntax = query(<language-syntax>).map(it => it.value)
  assert.eq(syntax.len(), 2)
  assert.eq(syntax.first(), syntax.last())
  assert.eq(query(<language-hidden>).first().value, (
    body: "python",
    display-name: false,
    display-icon: false,
  ))
  assert.eq(query(<language-fallback>).first().value, (body: "missing", defined: none))
  let headers = e.query(codly.codly-header)
  assert.eq(headers.map(it => text-of(it)), (
    "standalone-head",
    "plain-head",
    "element-head",
    "plain-header",
    "explicit-header",
    "inherited-header",
  ))
  let footers = e.query(codly.codly-footer)
  assert.eq(footers.map(it => text-of(it)), (
    "standalone-foot",
    "plain-foot",
    "element-foot",
    "explicit-footer",
    "plain-footer",
    "inherited-footer",
  ))
  let styled = query(<styled-cells>).map(it => it.value)
  assert.eq(styled, (
    ((kind: "header", fill: green), (kind: "footer", fill: blue)),
    ((kind: "header", fill: red), (kind: "footer", fill: green)),
    ((kind: "header", fill: green), (kind: "footer", fill: green)),
  ))
  assert.eq(query(<lines-seen>).map(it => it.value.number), (1, 2))
  assert.eq(query(<numbers-seen>).map(it => it.value), (1, 2))
  assert.eq(query(<highlights-seen>).first().value.color, rgb("#283593"))
  assert.eq(query(<annotations-seen>).first().value, (body: [note], num: 1))
}
