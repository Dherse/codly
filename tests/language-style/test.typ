#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 285pt, height: auto, margin: 5pt)

#let text-of(body) = {
  if body == none {
    ""
  } else if body.has("text") {
    body.text
  } else if body.has("child") {
    text-of(body.child)
  } else if body.has("body") {
    text-of(body.body)
  } else if body.has("children") {
    body.children.map(text-of).join()
  } else {
    ""
  }
}

#let radius = (top-left: 1pt, top-right: 2pt, bottom-right: 3pt, bottom-left: 4pt)
#let languages = (
  py: (
    name: [Python],
    icon: [P],
    color: red,
    radius: radius,
  ),
)

#show box: it => {
  if text-of(it.body) in ("PPython", "P", "Python") {
    [#metadata(it.radius)<badge-radius>#it]
  } else { it }
}

#let capture-lang = it => {
  let fields = e.fields(it)
  [#metadata((
      body: fields.body,
      display-name: fields.display-name,
      display-icon: fields.display-icon,
      radius: fields.radius,
      definition-radius: fields.languages.py.at("radius", default: none),
    ))<language-fields>#it]
}

// Both parts of the badge are shown by default.
#{
  show: codly.lang-set_(languages: languages, radius: radius)
  show: codly.lang-show_(capture-lang)
  codly.new(raw("both", lang: "py", block: true))
}

// Each visibility switch works independently, including the icon-only case.
#{
  show: codly.lang-set_(languages: languages, radius: 6pt, display-name: false)
  show: codly.lang-show_(capture-lang)
  codly.new(raw("icon", lang: "py", block: true))
}
#{
  show: codly.lang-set_(languages: languages, radius: 6pt, display-icon: false)
  show: codly.lang-show_(capture-lang)
  codly.new(raw("name", lang: "py", block: true))
}
#{
  show: codly.lang-set_(languages: languages, radius: 6pt, display-name: false, display-icon: false)
  show: codly.lang-show_(capture-lang)
  codly.new(raw("hidden", lang: "py", block: true))
}

// #129: image icons must survive when the language name is hidden.
#{
  show image: it => context [#metadata(measure(it))<badge-image>#it]
  show: codly.lang-set_(display-name: false, languages: (
    typ: (name: "Typst", icon: box(image("../../src/typst-small.png", height: 0.8em)), color: teal),
  ))
  codly.new(raw("image icon", lang: "typ", block: true))
}

#context {
  let fields = query(<language-fields>).map(it => it.value)
  assert.eq(fields.len(), 4)
  assert.eq(fields.map(it => (it.display-name, it.display-icon)), (
    (true, true),
    (false, true),
    (true, false),
    (false, false),
  ))
  assert.eq(fields.map(it => it.radius), (
    radius,
    6pt,
    6pt,
    6pt,
  ))
  assert.eq(fields.map(it => it.definition-radius), (
    radius,
    radius,
    radius,
    radius,
  ))

  let rendered = e.query(codly.codly-lang).map(text-of)
  assert.eq(rendered, ("PPython", "P", "Python", "", ""))
  assert.eq(query(<badge-radius>).map(it => it.value), (radius, radius, radius))
  let images = query(<badge-image>)
  assert.eq(images.len(), 1)
  assert(images.first().value.width > 0pt and images.first().value.height > 0pt)
}
