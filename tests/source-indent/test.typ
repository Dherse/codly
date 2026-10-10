#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 380pt, height: auto, margin: 8pt)
#set text(size: 9pt)
#show: codly.callout-set_(source-indent: true)
#show: codly.callout-show_(it => {
  [#metadata((
      line: e.fields(it).line,
      indent: e.fields(it).__indent,
      enabled: e.fields(it).source-indent,
    ))<indent-settings>#it]
})
#let comment(
  key,
) = [#metadata(key)<comment-start>Comment with enough words to wrap onto a second line in narrow blocks.]
#let source = "zero\n    four\n\t    eight\n    "
#show text: it => {
  if it.text in ("zero", "four", "eight") { [#metadata(it.text)<source-start>#it] } else { it }
}
#for outside in (false, true) {
  show: codly.number-set_(placement: if outside { "outside" } else { "inside" })
  codly.new(
    raw(source, block: true, tab-size: 4),
    skip-last-empty: false,
    gutters: (auto, (values: ("a", "b", "c", "d"), width: 30pt)),
    callouts: (
      (line: 1, body: comment("zero")),
      (line: 2, body: comment("four"), placement: "above"),
      (line: 3, body: comment("eight")),
      (line: 4, body: comment("blank")),
    ),
    annotations: ((start: 1, end: 3, content: [group]),),
  )
}
#context {
  let comments = query(<comment-start>)
  let sources = query(<source-start>)
  for key in ("zero", "four", "eight") {
    let expected = sources.filter(it => it.value == key).map(it => it.location().position().x)
    let actual = comments.filter(it => it.value == key).map(it => it.location().position().x)
    assert.eq(actual.len(), 2)
    for (a, b) in actual.zip(expected) { assert(calc.abs(a - b) < 0.01pt) }
  }
  let settings = query(selector(<indent-settings>).before(here())).map(it => it.value)
  assert.eq(settings.len(), 8)
  assert(settings.all(it => it.enabled))
  // Native raw tab expansion is the authority, not a hard-coded tab width.
  assert(settings.at(2).indent > settings.at(1).indent)
  assert.eq(settings.at(3).indent, settings.at(1).indent)
}

// Per-entry opt-out, numbering disabled, diff marker removal, and sublanguages.
#codly.new(raw("    no numbers", block: true), number-enabled: false, callouts: (
  (line: 1, body: [Note]),
))
#codly.new(raw("+    added", lang: "diff,py", block: true), callouts: (
  (line: 1, body: [Diff note]),
))
#codly.new(
  raw("    mixed", lang: "sh", block: true),
  sublangs: ((start: 1, end: 1, lang: "py"),),
  callouts: ((line: 1, body: [Opt out], source-indent: false),),
)
#codly.new(raw("    pointed", block: true), callouts: ((line: 1, pointer: 6, body: [Bubble]),))
#context {
  let settings = query(selector(<indent-settings>).before(here())).map(it => it.value)
  assert.eq(settings.last().indent, 0pt)
  assert.eq(settings.at(10).enabled, false)
}

// Comment typography must not be used to measure the code's indentation.
#{
  show: codly.theme("github-light", callout: (text: (font: "Source Sans 3", size: 7pt)))
  show text: it => if it.text == "return" {
    [#metadata(none)<font-source>#it]
  } else { it }
  codly.new(raw("    return font_code", lang: "py", block: true), callouts: (
    (line: 1, body: [#metadata(none)<font-comment>A proportional-font explanation.]),
  ))
}
#context {
  let source = query(<font-source>).first().location().position().x
  let comment = query(<font-comment>).first().location().position().x
  assert(calc.abs(source - comment) < 0.01pt)
}
