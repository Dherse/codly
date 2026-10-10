#import "../../codly.typ" as codly

#set page(width: 160pt, height: auto, margin: 5pt)

#let case = sys.inputs.at("case")
#show: codly.ref-set_(by: "item")

#let cases = (
  gutter-negative-width: (gutters: ((values: (), width: -1pt),)),
  gutter-negative-ratio: (gutters: ((values: (), width: -10%),)),
  gutter-negative-fraction: (gutters: ((values: (), width: -1fr),)),
  gutter-empty-fill: (gutters: ((values: (), fill: ()),)),
  gutter-invalid-value: (gutters: ((_ => true),)),
  filename-position: (file: "main.py", file-position: center),
  language-position: (lang-position: bottom + center),
  range-conflict: (range: (1, 2), ranges: ((2, 3),)),
  annotation-overlap: (annotations: ((start: 1, end: 3), (start: 2, end: 3))),
  annotation-touching: (annotations: ((start: 1, end: 2), (start: 2, end: 3))),
  annotation-label: (annotations: ((start: 1, label: <annotation>),)),
  item-without-tag: (block-label: <code>, highlights: ((line: 1, label: <item>),)),
  missing-offset: (offset-from: <missing>),
  callout-pointer-negative: (callouts: ((line: 1, pointer: -1, body: []),)),
  callout-pointer-past-end: (callouts: ((line: 1, pointer: 20, body: []),)),
  callout-negative-size: (callouts: ((line: 1, pointer: 1, pointer-size: -1pt, body: []),)),
  callout-negative-width: (callouts: ((line: 1, pointer: 1, bubble-width: -1pt, body: []),)),
  callout-negative-inset: (callouts: ((line: 1, pointer: 1, bubble-inset: -1pt, body: []),)),
  callout-negative-gap: (callouts: ((line: 1, pointer: 1, bubble-gap: -1pt, body: []),)),
  callout-negative-gap-y: (callouts: ((line: 1, pointer: 1, bubble-gap: (y: -1pt), body: []),)),
  callout-gap-keys: (callouts: ((line: 1, pointer: 1, bubble-gap: (z: 2pt), body: []),)),
  callout-gap-type: (callouts: ((line: 1, pointer: 1, bubble-gap: (x: "bad"), body: []),)),
  callout-negative-pointer-height: (
    callouts: ((line: 1, pointer: 1, pointer-height: -1pt, body: []),),
  ),
  callout-negative-pointer-width: (
    callouts: ((line: 1, pointer: 1, pointer-width: -1pt, body: []),),
  ),
)

#if case.starts-with("diff-") {
  let sources = (
    diff-language: ("+one", "diff,"),
    diff-languages: ("+one", "diff,py,c"),
    diff-hunk: ("@@ bad @@", "diff,py"),
    diff-incomplete: ("@@ -1,2 +1,2 @@\n one", "diff,py"),
    diff-counts: ("@@ -1,0 +1,1 @@\n one", "diff,py"),
    diff-extra: ("@@ -1 +1 @@\n one\n+extra", "diff,py"),
    diff-prefix: ("@@ -1 +1 @@\none", "diff,py"),
    diff-combined: ("@@@ -1 -1 +1 @@@", "diff,py"),
  )
  if case in ("diff-theme", "diff-syntax") {
    let resource = if case == "diff-theme" {
      (theme: "../aliases/99-local-resources.tmTheme")
    } else {
      (syntaxes: "../aliases/99-local-resources.sublime-syntax")
    }
    codly.new(raw("+one", lang: "diff,py", block: true, ..resource))
  } else {
    let (source, language) = sources.at(case)
    codly.new(raw(source, lang: language, block: true))
  }
} else if case.starts-with("padding-") {
  let cases = (
    padding-negative: -1pt,
    padding-axis-negative: (y: -1em),
    padding-key: (vertical: 2pt),
    padding-type: (left: "wrong"),
  )
  codly.new(raw("one", block: true), padding: cases.at(case))
} else if case == "highlight-palette-empty" {
  show: codly.highlight-set_(color: ())
  codly.new(raw("one", block: true), highlighted: (1,))
} else if case == "theme-palette-empty" {
  show: codly.theme("dark", highlight-colors: ())
  codly.new(raw("one", block: true), highlights: ((line: 1),))
} else if case == "theme-name" {
  show: codly.theme("does-not-exist")
  codly.new(raw("one", block: true))
} else if case == "theme-setting" {
  show: codly.theme("dark", forground: white)
  codly.new(raw("one", block: true))
} else if case == "theme-section" {
  show: codly.theme("dark", header: red)
  codly.new(raw("one", block: true))
} else if case == "theme-base" {
  show: codly.theme(42)
  codly.new(raw("one", block: true))
} else if case == "empty-fill" {
  show: codly.line-set_(fill: ())
  codly.new(raw("one", block: true))
} else if case == "filename-missing" {
  codly.new(path("no-such-source.py"))
} else if case == "bubble-negative-height" {
  show: codly.bubble-set_(pointer-height: -1pt)
  codly.new(raw("one", block: true), callouts: ((line: 1, pointer: 1, body: [Bad height]),))
} else if case == "highlight-label" {
  include "../issues/47-crash-label.typ"
} else if case == "duplicate-info" {
  [
    #codly.new(raw("one", block: true))<duplicate>
    #parbreak()
    #codly.new(raw("two", block: true))<duplicate>
  ]
  context { codly.info(<duplicate>) }
} else if case == "info-without-code" {
  [#metadata(none)<empty>]
  context { codly.info(<empty>) }
} else if case == "missing-reference" {
  ref(<missing-line:5>)
} else if case in ("alias-theme", "alias-syntax") {
  include "../aliases/errors.typ"
} else {
  [#figure(caption: [Code])[
    #codly.new(raw("one\ntwo\nthree", block: true), ..cases.at(case))
  ]<code>]
  if case == "item-without-tag" { ref(<item>) }
}
