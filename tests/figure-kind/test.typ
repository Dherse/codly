#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 400pt, height: auto, margin: 5pt)
#set document(title: "Codly listing figures")
#set text(lang: "en")
#let text-of(body) = {
  if body.has("text") { body.text } else if body.has("children") {
    body.children.map(text-of).join()
  } else if body.has("child") { text-of(body.child) } else if body.has("body") {
    text-of(body.body)
  } else { "" }
}

// Images, tables, and listings have separate counters.
#figure(rect(width: 15pt, height: 8pt), alt: "A small rectangle", caption: [Image])<image-before>
#figure(table(columns: 1)[Table], caption: [Table])<table-before>

// Elembic fields and identities must be accessible before layout.
#let code-block = codly.new(
  raw("raw_listing_token", block: true),
  radius: 6pt,
  block-label: <raw-code>,
)
#assert.eq(e.data(codly.new).eid, e.data(codly.codly).eid)
#assert.eq(e.fields(code-block).radius, 6pt)
#assert.eq(e.data(code-block).name, "codly")

@raw-code @raw-code:1 @marked @note
#figure(code-block, caption: [Raw input])<raw-code>
#figure(codly.new("string_listing_token", lang: "py"), caption: [String input])<string-code>
#figure(codly.new(path("source.py")), caption: [File input])<file-code>
#figure(
  codly.new(block[Code: #raw("wrapped_listing_token", block: true)]),
  caption: [Wrapped input],
)<wrapped-code>
#figure(
  codly.new(context raw("context_listing_token", block: true)),
  caption: [Context input],
)<context-code>

// Reference targets keep their kinds but use the enclosing listing's number.
#figure(caption: [Marked input])[
  #codly.new(
    raw("marked_listing_token\nsecond line", block: true),
    block-label: <marked-code>,
    highlights: ((line: 1, tag: "A", label: <marked>),),
    annotations: ((start: 2, content: [Note], label: <note>),),
  )
]<marked-code>

// The caller's explicit kind/supplement still wins.
#figure(
  codly.new("override_listing_token"),
  kind: image,
  caption: [Explicit image kind],
)<explicit-image>
#figure(
  codly.new("custom_listing_token"),
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Custom kind],
)<custom-code>

// Global auto-conversion must neither recurse nor duplicate rendering.
#[
  #show raw.where(block: true): codly.new
  #figure(raw("automatic_listing_token", block: true), caption: [Automatic input])<automatic-code>
  #figure(
    codly.new(raw("explicit_auto_listing_token", block: true)),
    caption: [Explicit with auto-conversion],
  )<explicit-auto-code>
  #figure(
    codly.new(raw("-old_listing_token\n+new_listing_token", lang: "diff,py", block: true)),
    caption: [Diff input],
  )<diff-code>
]

// Kind-specific rules and outlines work through Typst's native raw selector.
#[
  #show figure.where(kind: raw): set figure.caption(position: top)
  #show figure.caption: it => [#metadata(none)<styled-caption>#it]
  #show: codly.line-show_(it => [#metadata(none)<styled-source>#it])
  #figure(codly.new("styled_listing_token"), caption: [Caption above])<styled-code>
]
#figure(
  rect(width: 15pt, height: 8pt),
  alt: "Another small rectangle",
  caption: [Second image],
)<image-after>
#outline(target: figure.where(kind: raw), title: [Listings])

#context {
  let listings = (
    <raw-code>,
    <string-code>,
    <file-code>,
    <wrapped-code>,
    <context-code>,
    <marked-code>,
    <automatic-code>,
    <explicit-auto-code>,
    <diff-code>,
    <styled-code>,
  )
  for (index, target) in listings.enumerate() {
    let listing = query(target).first()
    assert.eq(listing.kind, raw)
    assert.eq(text-of(listing.supplement), "Listing")
    assert.eq(counter(figure.where(kind: raw)).at(target), (index + 1,))
  }
  assert.eq(query(figure.where(kind: raw)).len(), listings.len())
  assert(
    query(<styled-caption>).first().location().position().y
      < query(<styled-source>).first().location().position().y,
  )
  assert.eq(query(<image-before>).first().kind, image)
  assert.eq(query(<table-before>).first().kind, table)
  assert.eq(query(<explicit-image>).first().kind, image)
  assert.eq(query(<custom-code>).first().kind, "algorithm")
  assert.eq(counter(figure.where(kind: image)).at(<image-after>), (3,))
  assert.eq(query(<raw-code:1>).first().kind, "codly-line")
  assert.eq(query(<marked>).first().kind, "codly-referencer")
  assert.eq(query(<note>).first().kind, "codly-referencer")
  assert.eq(e.fields((query(<marked>).first().numbering)()).block, <marked-code>)
  assert.eq(e.fields((query(<note>).first().numbering)()).block, <marked-code>)
  assert.eq(codly.info(<raw-code>), (last-number: 1, lines: 1))
}
