#import "../../codly.typ" as codly
#import "../../src/themes.typ" as themes

// Captured from the declarations before the JSON-to-YAML migration.
// Compare effective Elembic metadata, including field order and type identities;
// documentation can evolve without changing construction or style semantics.
#let constructors = (
  ("language", codly.language),
  ("diff", codly.diff),
  ("gutter-column", codly.gutter-column),
  ("sublang", codly.sublang),
  ("rainbow", codly.rainbow),
  ("indent-guides", codly.indent-guides),
  ("smart-skip", codly.smart-skip),
  ("highlight-config", codly.highlight-config),
  ("annotation-config", codly.annotation-config),
  ("callout-config", codly.callout-config),
  ("range", codly.range),
  ("skip", codly.skip),
  ("highlighted-line", codly.highlighted-line),
  ("unnumbered-line", codly.unnumbered-line),
  ("ref", codly.ref),
  ("line-ref", codly.line-ref),
  ("highlight-ref", codly.highlight-ref),
  ("annotation-ref", codly.annotation-ref),
  ("highlight", codly.highlight),
  ("line", codly.line),
  ("header", codly.header),
  ("footer", codly.footer),
  ("lang", codly.lang),
  ("file", codly.file),
  ("annotation", codly.annotation),
  ("bubble", codly.bubble),
  ("callout", codly.callout),
  ("number", codly.number),
  ("sublang-block", codly.sublang-block),
  ("codly", codly.codly),
  ("theme-style", themes.__style),
)
#let field-signature(field) = (
  field.name,
  field.typeinfo.name,
  field.typeinfo.type-kind,
  repr(field.typeinfo.input),
  repr(field.typeinfo.output),
  codly.e.repr(field.default),
  field.required,
  field.named,
  field.folds,
  if field.fold == none { none } else {
    (repr(field.fold.folder), codly.e.repr(field.fold.default))
  },
  field.internal,
  field.synthesized,
  repr(field.meta),
)
#let actual = constructors.map(((name, constructor)) => {
  let data = codly.e.data(constructor)
  (
    name: name,
    identity: data.name,
    id: data.at("eid", default: data.at("tid", default: none)),
    labelable: if "elem-args" in data { repr(data.elem-args.named().labelable) } else { none },
    allow-unknown-fields: data.allow-unknown-fields,
    fields: data.all-fields.values().map(field-signature),
  )
})
#let expected = json("signatures.json").declarations
#assert.eq(actual.len(), expected.len())
#for (a, b) in actual.zip(expected) {
  assert.eq(a.keys(), b.keys(), message: a.name)
  for name in a.keys().filter(name => name != "fields") {
    assert.eq(a.at(name), b.at(name), message: a.name + "." + name)
  }
  assert.eq(a.fields.len(), b.fields.len(), message: a.name + " field count")
  for (field, original) in a.fields.zip(b.fields) {
    assert.eq(field, original, message: a.name + "." + field.first())
  }
}

// Function representations alone cannot validate evaluated callback defaults.
#let defaults(constructor) = codly.e.data(constructor).default-fields
#assert.eq(defaults(codly.line).fill, (luma(240), none))
#assert.eq((defaults(codly.highlight).fill)(red), red.lighten(80%))
#assert.eq((defaults(codly.highlight).stroke)(red), 0.5pt + red)
#assert.eq((defaults(codly.lang).fill)((color: blue)), blue.lighten(80%))
#assert.eq((defaults(codly.lang).stroke)((color: blue)), blue + 0.5pt)
#assert.eq((defaults(codly.number).numbering)(7), numbering("1", 7))
#assert.eq((defaults(codly.ref).numbering)(7), numbering("1", 7))
#assert.eq((defaults(codly.annotation).numbering)(7), numbering("(1)", 7))
#assert.eq((defaults(codly.annotation-config).numbering)(7), numbering("(1)", 7))

// Pair fields retain optional positional arguments and named construction.
#assert.eq(codly.e.fields(codly.range(2, 4)), (start: 2, end: 4))
#assert.eq(codly.e.fields(codly.range(start: 2)), (start: 2, end: none))
#assert.eq(codly.e.fields(codly.skip(3, 2)), (position: 3, length: 2))
#assert.eq(codly.e.fields(codly.highlighted-line(4, blue)), (line: 4, color: blue))
#assert.eq(codly.e.fields(codly.unnumbered-line(5, [x])), (line: 5, fill: [x]))

#let cast(value, constructor) = {
  let (success, converted) = codly.e.types.cast(value, constructor)
  assert(success, message: repr(value))
  codly.e.fields(converted)
}
#assert.eq(cast("Python", codly.language), (name: "Python", color: none, icon: none))
#assert.eq(cast((name: "Python", extra: 7), codly.language).extra, 7)
#assert.eq(cast((2, 4), codly.range), (start: 2, end: 4))
#assert.eq(cast((position: 3), codly.skip), (position: 3, length: 1))
#assert.eq(cast(4, codly.highlighted-line), (line: 4, color: none))
#assert.eq(cast(5, codly.unnumbered-line), (line: 5, fill: []))
#assert.eq(cast(false, codly.smart-skip), (first: false, last: false, rest: false))
#assert.eq(cast((rest: true, first: false), codly.smart-skip), (
  first: false,
  last: true,
  rest: true,
))
#for constructor in (codly.diff, codly.rainbow, codly.indent-guides) {
  assert.eq(cast(false, constructor).enabled, false)
}
#assert.eq(cast((none, "+", 3), codly.gutter-column).values, (none, "+", 3))
#let row-value = row => row.number
#assert.eq((cast(row-value, codly.gutter-column).values)((number: 8)), 8)
#assert.eq(cast((line: 2), codly.highlight-config).start, 0)
#assert.eq(cast((line: 2), codly.highlight-config).end, 999999999)
#assert.eq(cast((start: 2), codly.annotation-config).end, 2)

// Shared callout fields distinguish entry overrides from independent bubble
// defaults. Entry and callout styling inherit auto; bubble styling owns paint,
// geometry, and placement defaults.
#let entry = defaults(codly.callout-config)
#let callout = defaults(codly.callout)
#let bubble = defaults(codly.bubble)
#for name in (
  "source-indent",
  "placement",
  "pointer",
  "bubble-gap",
  "pointer-align",
  "pointer-size",
  "pointer-height",
  "pointer-width",
  "pointer-offset",
  "bubble-align",
  "bubble-fill",
  "bubble-stroke",
  "bubble-inset",
  "bubble-outset",
  "bubble-radius",
  "bubble-width",
) {
  assert.eq(entry.at(name), auto, message: "entry." + name)
}
#assert.eq(callout.at("source-indent"), false)
#assert.eq(callout.placement, "below")
#assert.eq(callout.pointer, none)
#for name in (
  "bubble-gap",
  "pointer-align",
  "pointer-size",
  "pointer-height",
  "pointer-width",
  "pointer-offset",
  "bubble-align",
  "bubble-fill",
  "bubble-stroke",
  "bubble-inset",
  "bubble-outset",
  "bubble-radius",
  "bubble-width",
) {
  assert.eq(callout.at(name), auto, message: "callout." + name)
}
#assert.eq(bubble.gap, 0.5em)
#assert.eq(bubble.at("pointer-size"), 0.4em)
#assert.eq(bubble.fill, luma(245))
#assert.eq(bubble.stroke, 0.6pt + luma(80))
#assert.eq(bubble.inset, (x: 0.5em, y: 0.3em))
#assert.eq(bubble.radius, 2pt)

