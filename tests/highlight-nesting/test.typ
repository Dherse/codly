#import "../../src/lib.typ": __codly-line-show

// Expose the nesting as delimiters so we can check the complete structure,
// including whether an outer highlight is emitted more than once.
#let wrap(body, highlight: none) = {
  [<#highlight.tag>] + body + [</#highlight.tag>]
}

#let text-of(body) = {
  if body.has("text") {
    body.text
  } else if body.has("children") {
    body.children.map(text-of).join()
  } else {
    ""
  }
}

#let check(highlights, expected) = {
  show figure.where(kind: "__codly-raw-line"): it => []
  show raw.line: it => assert.eq(text-of(it.body), expected)
  __codly-line-show(wrap, none, (
    body: raw.line(1, 1, "abcdefghi", [abcdefghi]),
    highlights: highlights.map(hl => (line: 1, ..hl)),
    smart-indent: false,
    block-label: none,
  ))
}

// Plain text, three nesting levels, sibling highlights, and gaps.
#check((
  (start: 2, end: 8, tag: "outer"),
  (start: 3, end: 5, tag: "middle"),
  (start: 4, end: 4, tag: "inner"),
  (start: 7, end: 7, tag: "sibling"),
), "a<outer>b<middle>c<inner>d</inner>e</middle>f<sibling>g</sibling>h</outer>i")

// Shared starts and ends must preserve one wrapper per highlight.
#check((
  (start: 1, end: 9, tag: "outer"),
  (start: 1, end: 3, tag: "left"),
  (start: 7, end: 9, tag: "right"),
), "<outer><left>abc</left>def<right>ghi</right></outer>")

// Equal spans retain the existing innermost-first input order.
#check((
  (start: 2, end: 8, tag: "first"),
  (start: 2, end: 8, tag: "second"),
), "a<second><first>bcdefgh</first></second>i")

// Adjacent highlights at the same depth remain separate.
#check((
  (start: 2, end: 4, tag: "left"),
  (start: 5, end: 7, tag: "right"),
), "a<left>bcd</left><right>efg</right>hi")

// Crossing spans split as necessary to produce properly nested elements.
#check((
  (start: 2, end: 5, tag: "left"),
  (start: 4, end: 7, tag: "right"),
), "a<left>bc</left><right><left>de</left>fg</right>hi")

// A span continuing past the line is closed at the end of the content.
#check(((start: 3, end: 100, tag: "tail"),), "ab<tail>cdefghi</tail>")
#check(((start: 20, end: 30, tag: "outside"),), "abcdefghi")
#check((), "abcdefghi")
