#import "../../codly.typ" as codly
#import "@preview/elembic:1.1.1" as e

#set page(width: 240pt, height: auto, margin: 5pt)

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

#let line-seen(it) = {
  let fields = e.fields(it)
  [#metadata((
      number: fields.number,
      separator: fields.separator,
      body: text-of((fields.numbering)(fields.number)),
      suffix: fields.suffix,
    ))<line-ref-seen>#it]
}

#let highlight-seen(it) = {
  let fields = e.fields(it)
  [#metadata((
      line: fields.line,
      item: fields.item,
      by: fields.by,
      separator: fields.separator,
      body: if fields.numbering == auto { "auto" } else {
        text-of((fields.numbering)(fields.line))
      },
    ))<highlight-ref-seen>#it]
}

#let annotation-seen(it) = {
  let fields = e.fields(it)
  [#metadata((
      line: fields.line,
      item: fields.item,
      by: fields.by,
      separator: fields.separator,
      body: if fields.numbering == auto { "auto" } else {
        text-of((fields.numbering)(fields.line))
      },
    ))<annotation-ref-seen>#it]
}

// Each generated target remains a native reference while exposing a separate
// element and scoped style hooks for its semantic kind.
#{
  show: codly.line-ref-set_(separator: " line ", numbering: n => [L#n])
  show: codly.highlight-ref-set_(separator: " highlight ", numbering: n => [H#n])
  show: codly.annotation-ref-set_(separator: " annotation ", numbering: n => [A#n])
  show: codly.line-ref-show_(line-seen)
  show: codly.highlight-ref-show_(highlight-seen)
  show: codly.annotation-ref-show_(annotation-seen)

  [
    @styled:12 @styled-highlight @styled-note
    #figure(caption: [Styled references])[
      #codly.new(
        raw("one\ntwo", block: true),
        offset: 10,
        block-label: <styled>,
        highlights: ((line: 12, start: 0, end: 3, label: <styled-highlight>),),
        annotations: ((start: 2, content: [note], label: <styled-note>),),
      )
    ]<styled>
  ]
}

// Item references use the same native targets and own element hooks.
#{
  show: codly.ref-set_(by: "item")
  show: codly.highlight-ref-show_(highlight-seen)
  show: codly.annotation-ref-show_(annotation-seen)

  [
    @item-highlight @item-note
    #figure(caption: [Item references])[
      #codly.new(
        raw("one", block: true),
        block-label: <items>,
        highlights: ((line: 1, tag: [tag], label: <item-highlight>),),
        annotations: ((start: 1, content: [note], label: <item-note>),),
      )
    ]<items>
  ]
}

#context {
  for target in (<styled:12>, <styled-highlight>, <styled-note>) {
    let reference = (query(target).first().numbering)()
    assert.eq(e.fields(reference).body, [])
  }
  assert.eq(query(<line-ref-seen>).map(it => it.value), (
    (number: 12, separator: " line ", body: "L12", suffix: none),
  ))
  assert.eq(query(<highlight-ref-seen>).map(it => it.value), (
    (line: 12, item: none, by: "line", separator: " highlight ", body: "H12"),
    (line: 1, item: [tag], by: "item", separator: auto, body: "auto"),
  ))
  assert.eq(query(<annotation-ref-seen>).map(it => it.value), (
    (line: 12, item: [note], by: "line", separator: " annotation ", body: "A12"),
    (line: 1, item: [note], by: "item", separator: auto, body: "auto"),
  ))
}
