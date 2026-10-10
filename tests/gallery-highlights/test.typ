#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 480pt, height: auto, margin: 3pt)
#let text-of(body) = {
  if body.has("text") { body.text } else if body.has("children") {
    body.children.map(text-of).join()
  } else if body.has("child") { text-of(body.child) } else if body.has("body") {
    text-of(body.body)
  } else { "" }
}

// Check the highlighted source content, not just the gallery screenshot.
// Positions are one-based and inclusive, and include indentation.
#show: codly.highlight-show_(it => {
  let fields = e.fields(it)
  let expected = if fields.highlight.line == 3 { "value * 2" } else if fields.highlight.line == 4 {
    "operation()"
  } else { "raise" }
  assert.eq(text-of(fields.body), expected)
  [#metadata(expected)<gallery-highlight>#it]
})
// Exercise the actual gallery sources, so changing a range there breaks this test.
#include "../../examples/annotations.typ"
#include "../../examples/themes.typ"

#context assert.eq(query(<gallery-highlight>).map(it => it.value), (
  "operation()",
  "raise",
  ..range(6).map(_ => "value * 2"),
))
