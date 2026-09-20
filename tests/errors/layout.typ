#import "../../codly.typ" as codly

#set page(width: 160pt, height: auto, margin: 5pt)

#let case = sys.inputs.at("case")
#show: codly.ref-set_(by: "item")

#let cases = (
  range-conflict: (range: (1, 2), ranges: ((2, 3),)),
  annotation-overlap: (annotations: ((start: 1, end: 3), (start: 2, end: 3))),
  annotation-touching: (annotations: ((start: 1, end: 2), (start: 2, end: 3))),
  annotation-label: (annotations: ((start: 1, label: <annotation>),)),
  item-without-tag: (block-label: <code>, highlights: ((line: 1, label: <item>),)),
  missing-offset: (offset-from: <missing>),
)

#if case == "highlight-label" {
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
