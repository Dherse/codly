#import "../../src/lib.typ": __codly-line-show, __codly-line-loop

#set page(width: 160pt, height: auto, margin: 5pt)

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
  } else if body.has("child") {
    text-of(body.child)
  } else if body.has("body") {
    text-of(body.body)
  } else {
    ""
  }
}

#let check(highlights, expected, body: [abcdefghi]) = {
  show figure.where(kind: "__codly-raw-line"): it => []
  show raw.line: it => assert.eq(text-of(it.body), expected)
  __codly-line-show(wrap, none, none, (
    body: raw.line(1, 1, "", body),
    highlights: highlights.map(hl => (line: 1, ..hl)),
    smart-indent: false,
    block-label: none,
  ))
}

// Plain text, three nesting levels, sibling highlights, and gaps.
#check(
  (
    (start: 2, end: 8, tag: "outer"),
    (start: 3, end: 5, tag: "middle"),
    (start: 4, end: 4, tag: "inner"),
    (start: 7, end: 7, tag: "sibling"),
  ),
  "a<outer>b<middle>c<inner>d</inner>e</middle>f<sibling>g</sibling>h</outer>i",
)

// Shared starts and ends must preserve one wrapper per highlight.
#check(
  (
    (start: 1, end: 9, tag: "outer"),
    (start: 1, end: 3, tag: "left"),
    (start: 7, end: 9, tag: "right"),
  ),
  "<outer><left>abc</left>def<right>ghi</right></outer>",
)

// Equal spans retain the existing innermost-first input order.
#check(
  (
    (start: 2, end: 8, tag: "first"),
    (start: 2, end: 8, tag: "second"),
  ),
  "a<second><first>bcdefgh</first></second>i",
)

// Adjacent highlights at the same depth remain separate.
#check(
  (
    (start: 2, end: 4, tag: "left"),
    (start: 5, end: 7, tag: "right"),
  ),
  "a<left>bcd</left><right>efg</right>hi",
)

// Crossing spans split as necessary to produce properly nested elements.
#check(
  (
    (start: 2, end: 5, tag: "left"),
    (start: 4, end: 7, tag: "right"),
  ),
  "a<left>bc</left><right><left>de</left>fg</right>hi",
)

// A span continuing past the line is closed at the end of the content.
#check(((start: 3, end: 100, tag: "tail"),), "ab<tail>cdefghi</tail>")
#check(((start: 20, end: 30, tag: "outside"),), "abcdefghi")
#check((), "abcdefghi")

// Grapheme clusters stay whole when a boundary lands inside a combining
// character or an emoji. Positions use the source string's character offsets.
#check(((start: 2, end: 2, tag: "accent"),), "<accent>á</accent>bc", body: text("ábc"))
#check(((start: 2, end: 2, tag: "emoji"),), "a<emoji>🙂</emoji>b", body: text("a🙂b"))

// Styled content is traversed for text checks and remains intact in a span.
#check(
  ((start: 3, end: 6, tag: "styled"),),
  "ab<styled>cdef</styled>gh",
  body: [ab#text(fill: red)[cd]#strong[ef]gh],
)

// Empty spans emit nothing; equal geometry preserves distinct tags and order.
#check(((start: 4, end: 3, tag: "empty"),), "abcdef", body: [abcdef])
#check(
  ((start: 2, end: 2, tag: "first"), (start: 2, end: 2, tag: "second")),
  "a<second><first>b</first></second>c",
  body: [abc],
)

// Duplicate records collapse even when separated by another equal span.
#check(
  (
    (start: 2, end: 8, tag: "first"),
    (start: 2, end: 8, tag: "second"),
    (start: 2, end: 8, tag: "first"),
  ),
  "a<second><first>bcdefgh</first></second>i",
)

// Whitespace runs are atomic even when several boundaries fall inside them.
#check(
  (
    (start: 2, end: 9, tag: "outer"),
    (start: 5, end: 6, tag: "inner"),
  ),
  "<outer>  ab<inner>   </inner>cd</outer> e",
  body: text("  ab   cd e"),
)

// Per-line indexing uses displayed numbers, including offsets from each skip.
#context {
  let first = (line: 11, start: 1, end: 2)
  let second = (line: 14, start: 1, end: 3)
  let last = (line: 19, start: 2, end: 3)
  let expected = ("11": (first,), "14": (second,), "15": (), "19": (last,))
  let render(line, highlights: none, ..args) = {
    if line.func() == raw.line {
      assert.eq(highlights, expected.at(str(line.number)))
    }
    line
  }
  let result = __codly-line-loop(
    render,
    number => [],
    (first: false, rest: false, last: false),
    range(1, 5).map(number => raw.line(number, 4, "abc", [abc])),
    (), // annotations
    none, // ranges
    ((position: 2, length: 2), (position: 4, length: 3)),
    false, // skip-last-empty
    false, // number-enabled
    [skip],
    [], // skip-number
    none, // codly-annotation
    none, // codly-annotation-ref
    none, // ref-set
    (last, second, first, (line: 50, start: 1, end: 2)),
    false, // smart-indent
    none, // block-label
    10, // offset
    [], // lang-block
  )
  assert.eq(result.lines_to_number, (11, -99999999, 14, 15, -99999999, 19))
}
